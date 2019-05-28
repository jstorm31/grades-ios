//
//  Notification.swift
//  GradesNotificationExtension
//
//  Created by Jiří Zdvomka on 12/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

typealias NotificationContent = (title: String, text: String)

struct Notification {
	var id: Int
	var courseCode: String = ""
	var texts: [NotificationText] = []
	var url: String?
	
	/// Extract content from notification
	func getContent() -> NotificationContent {
		if let locale = Locale.current.languageCode, let item = texts.first(where: { $0.identifier == locale }) {
			return (title: item.title, text: item.text)
		} else if let item = texts.first(where: { $0.identifier == "en" }) {
			return (title: item.title, text: item.text)
		}
		return !texts.isEmpty ? (title: texts[0].title, text: texts[0].text) : (title: "", text: "")
	}
}

extension Notification: Decodable {
	enum CodingKeys: String, CodingKey {
		case id, courseCode, url
		case texts = "notificationTextDtos"
	}
}

struct NotificationText: Decodable {
	var identifier: String = ""
	var title: String = ""
	var text: String = ""
}

struct Notifications: Decodable {
	var notifications: [Notification] = []
}