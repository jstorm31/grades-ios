//
//  Notification.swift
//  GradesNotificationExtension
//
//  Created by Jiří Zdvomka on 12/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

struct Notification: Decodable {
	var id: Int
	var courseCode: String = ""
	var texts: [NotificationText] = []
	var url: String?
	
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
