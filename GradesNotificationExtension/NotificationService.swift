//
//  NotificationService.swift
//  GradesNotificationExtension
//
//  Created by Jiří Zdvomka on 12/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import SwiftKeychainWrapper
import UserNotifications

typealias NotificationContent = (title: String, text: String)

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
	
	private let config = EnvironmentConfiguration.shared
	private lazy var keychainWrapper = KeychainWrapper(serviceName: config.keychain.serviceName,
													   accessGroup: config.keychain.accessGroup)
	private var credentials: Credentials?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
		guard let bestAttemptContent = bestAttemptContent else { return }
		
		loadCredentialsFromKeychain()
		authenticate { content, text in
			if let content = content {
				bestAttemptContent.title = content.title
				bestAttemptContent.body = content.text
			}
			contentHandler(bestAttemptContent)
		}
		
//		bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
//		contentHandler(bestAttemptContent)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
			bestAttemptContent.title = "\(bestAttemptContent.title) [expired]"
            contentHandler(bestAttemptContent)
        }
    }

}

private extension NotificationService {
	func authenticate(completion: @escaping (NotificationContent?, String) -> Void) {
		guard let credentials = credentials else { return completion(nil, "cred") }
		
		if let expiresAt = credentials.expiresAt, expiresAt.timeIntervalSinceNow.sign == FloatingPointSign.plus {
			// Valid access token -> fetch notification content
			fetchNotificationContent { content, text in
				completion(content, text)
			}
		} else {
			// Get new access token
			completion(nil, "expired, \(credentials.expiresAt)\n\(Date())")
		}
	}
	
	func fetchNotificationContent(completion: @escaping (NotificationContent?, String) -> Void) {
		guard let credentials = credentials, let accessToken = credentials.accessToken else {
			completion(nil, "token nil")
			return
		}
		
		// Build request
		let base = config.gradesAPI["BaseURL"]! as String
//		let endpoint = (config.gradesAPI["UserNewNotifications"]! as String).replacingOccurrences(of: ":username", with: "zdvomjir")
		var request = URLRequest(url: URL(string: "\(base)/public/notifications/zdvomjir/new")!)
		request.httpMethod = "GET"
		request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
		
		// Make request
		let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
			if let error = error {
				completion(nil, error.localizedDescription)
				return
			}

			guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
				completion(nil, "Request failed")
				return
			}

			do {
				let wrapper = try JSONDecoder().decode(Notifications.self, from: data)
				if !wrapper.notifications.isEmpty {
					if let content = self?.getNotificationContent(wrapper.notifications[0]) {
						completion(content, "OK")
					}
				}
				completion(nil, "Empty")

			} catch {
				completion(nil, "Decoding failed")
			}
		}
		task.resume()
	}
	
	/// Extract content from notification
	func getNotificationContent(_ notification: Notification) -> NotificationContent {
		if let locale = Locale.current.languageCode, let item = notification.texts.first(where: { $0.identifier == locale }) {
			return (title: item.title, text: item.text)
		} else if let item = notification.texts.first(where: { $0.identifier == "en" }) {
			return (title: item.title, text: item.text)
		}
		return !notification.texts.isEmpty
			? (title: notification.texts[0].title, text: notification.texts[0].text)
			: (title: "", text: "")
	}
	
	func loadCredentialsFromKeychain() {
		if credentials == nil {
			credentials = Credentials(refreshToken: keychainWrapper.string(forKey: "refreshToken"),
									  accessToken: keychainWrapper.string(forKey: "accessToken"),
									  expiresAt: keychainWrapper.string(forKey: "expiresAt")?.toDate())
		}
	}
}

