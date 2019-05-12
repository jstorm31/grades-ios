//
//  NotificationService.swift
//  GradesNotificationExtension
//
//  Created by Jiří Zdvomka on 12/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import SwiftKeychainWrapper
import UserNotifications

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
		
		var credentials = self.credentials
		if credentials == nil {
			credentials = loadCredentialsFromKeychain()
		}
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
			bestAttemptContent.body = "Expires at: \(credentials!.accessToken ?? "nil")"
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

private extension NotificationService {
	func loadCredentialsFromKeychain() -> Credentials {
		return Credentials(refreshToken: keychainWrapper.string(forKey: "refreshToken"),
								  accessToken: keychainWrapper.string(forKey: "accessToken"),
								  expiresAt: keychainWrapper.string(forKey: "expiresAt")?.toDate())
	}
}

struct Credentials {
	let refreshToken: String?
	let accessToken: String?
	let expiresAt: Date?
}
