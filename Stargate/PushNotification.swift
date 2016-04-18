//
//  PushNotification.swift
//  Stargate
//
//  Created by Kyle McAlpine on 18/04/2016.
//
//

import Foundation

public typealias PushNotificationParams = [NSObject : AnyObject]
public typealias PushNotificationCallback = (PushNotificationParams) -> ()

public protocol NotificationCatcher: class {
    func catchNotification(notification: PushNotification)
}

private var defaultPushNotificationKey = "notification_id"

public struct PushNotification: Routeable {
    public let params: PushNotificationParams
    
    public static func setDefaultPushNotificationKey(key: String) { defaultPushNotificationKey = key }
    
    public func matchesRoute(route: Route) -> Bool {
        if case let .PushNotification(_, pushNotificationKey) = route.callback {
            if let payload = self.params["aps"] as? [NSObject : AnyObject], notification = payload[pushNotificationKey ?? defaultPushNotificationKey] as? String {
                let regex = try? NSRegularExpression(pattern: route.regex, options: .CaseInsensitive)
                let numberOfMatches = regex?.numberOfMatchesInString(notification, options: [], range: NSMakeRange(0, notification.characters.count))
                return numberOfMatches > 0
            }
        }
        return false
    }
}