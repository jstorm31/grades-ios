//
//  Notification.swift
//  GradesNotificationExtension
//
//  Created by Jiří Zdvomka on 12/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

typealias NotificationContent = (title: String, text: String)

struct PushNotification {
    var id: Int
    var courseCode: String = ""
    var texts: [NotificationText] = []
    var url: String?
    var badgeCount: Int = 1

    /// Extract content from notification
    func getContent() -> NotificationContent {
        if let locale = Locale.current.languageCode, let item = texts.first(where: { $0.identifier == locale }) {
            return (title: item.title, text: item.text)
        } else if let item = texts.first(where: { $0.identifier == "en" }) {
            return (title: item.title, text: item.text)
        }
        return !texts.isEmpty ? (title: texts[0].title, text: texts[0].text) : (title: "", text: "")
    }

    /// Create a new notification by decoding from a dictionary
    static func decode(from userInfo: [AnyHashable: Any]) -> Self? {
        guard let idString = userInfo["notificationId"] as? String, let id = Int(idString) else {
            return nil
        }

        if let courseCode = userInfo["courseCode"] as? String {
            return PushNotification(id: id, courseCode: courseCode, texts: [], url: nil, badgeCount: 1)
        }

        return PushNotification(id: id)
    }
}

extension PushNotification: Decodable {
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
    var notifications: [PushNotification] = []
}
