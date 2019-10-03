//
//  NotificationService.swift
//  GradesNotificationExtension
//
//  Created by Jiří Zdvomka on 12/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import SwiftKeychainWrapper
import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
	
	private let config = EnvironmentConfiguration.shared
	private lazy var keychainWrapper = KeychainWrapper(serviceName: config.keychain.serviceName,
													   accessGroup: config.keychain.accessGroup)
	private var credentials: Credentials?
	
	// MARK: Methods

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
		
		guard let bestAttemptContent = bestAttemptContent else { return }
		guard let idString = bestAttemptContent.userInfo["notificationId"] as? String,
			let notificationId = Int(idString) else { return }
        
		loadCredentialsFromKeychain()
		fetchNotification(withId: notificationId) { notification in
			if let notification = notification {
				let (title, text) = notification.getContent()
				bestAttemptContent.title = title
				bestAttemptContent.body = text
                bestAttemptContent.badge = NSNumber(integerLiteral: notification.badgeCount)
				bestAttemptContent.userInfo["courseCode"] = notification.courseCode
			}
			contentHandler(bestAttemptContent)
		}
    }
}

private extension NotificationService {
	
	/**
		Checks accessToken, obtains a new one if expired and fetches notifications content
		- Returns content of the notification as a parametr in the completion closure or nil if the fetch has been unsucessful
	*/
	func fetchNotification(withId id: Int, completion: @escaping (Notification?) -> Void) {
		guard let credentials = credentials else { return completion(nil) }
		
		if let expiresAt = credentials.expiresAt, expiresAt.timeIntervalSinceNow.sign == FloatingPointSign.plus {
			fetchNotificationContent(id) { notification in
				completion(notification)
			}
		} else if credentials.refreshToken != "" {
			obtainAccessToken() { [weak self] success in
				if success == true {
					self?.fetchNotificationContent(id) { notification in
						completion(notification)
					}
				} else {
					completion(nil)
				}
			}
		} else {
			completion(nil)
		}
	}
	
	/// Makes notification HTTP content request
	func fetchNotificationContent(_ notificationId: Int, completion: @escaping (Notification?) -> Void) {
		guard let credentials = credentials else {
			completion(nil)
			return
		}
		
		// Build request
		let base = config.gradesAPI["BaseURL"]! as String
		var request = URLRequest(url: URL(string: "\(base)/public/notifications/\(credentials.username ?? "")/new")!)
		request.httpMethod = "GET"
		request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
		request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
		
		
		// Make request
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
				completion(nil)
				return
			}

			do {
				let wrapper = try JSONDecoder().decode(Notifications.self, from: data)
                
				if var notification = wrapper.notifications.first(where: { $0.id == notificationId }) {
                    notification.badgeCount = wrapper.notifications.count
					completion(notification)
				} else {
					completion(nil)
				}
			} catch {
				completion(nil)
			}
		}
		task.resume()
	}
	
	/// Request new access token from OAuth server
	func obtainAccessToken(completion: @escaping (Bool) -> Void) {
		guard let credentials = credentials else {
			completion(false)
			return
		}
		
		// Build request
		
		var request = URLRequest(url: URL(string: config.auth.tokenUrl)!)
		request.httpMethod = "POST"
		request.setValue("Basic \(config.auth.clientHash)", forHTTPHeaderField: "Authorization")
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		let body = "grant_type=refresh_token&refresh_token=\(credentials.refreshToken)"
		request.httpBody = body.data(using: .utf8)
		
		let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
			guard error == nil, let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
				completion(false)
				return
			}
			
			do {
				let tokenResponse = try JSONDecoder().decode(AuthTokenResponse.self, from: data)

				// Set new tokens
				self?.credentials?.accessToken = tokenResponse.accessToken.safeStringByRemovingPercentEncoding
				self?.credentials?.refreshToken = tokenResponse.refreshToken.safeStringByRemovingPercentEncoding
				self?.credentials?.expiresAt = Date(timeInterval: tokenResponse.expiresIn, since: Date())
				self?.saveCredentialsToKeychain()
				completion(true)
			} catch {
				completion(false)
			}
		}

		// Make request
		task.resume()
	}
	
	func loadCredentialsFromKeychain() {
		if credentials == nil {
			credentials = Credentials(refreshToken: keychainWrapper.string(forKey: "refreshToken") ?? "",
									  accessToken: keychainWrapper.string(forKey: "accessToken") ?? "",
									  username: keychainWrapper.string(forKey: "username"),
									  expiresAt: keychainWrapper.string(forKey: "expiresAt")?.toDate())
		}
	}
	
	func saveCredentialsToKeychain() {
		guard let credentials = credentials else { return }
		
		keychainWrapper.set(credentials.refreshToken, forKey: "refreshToken", withAccessibility: .afterFirstUnlock)
		keychainWrapper.set(credentials.accessToken, forKey: "accessToken", withAccessibility: .afterFirstUnlock)
		
		guard let expiresAt = credentials.expiresAt else { return }
		keychainWrapper.set(expiresAt.toString(), forKey: "expiresAt", withAccessibility: .afterFirstUnlock)
	}
	
}

