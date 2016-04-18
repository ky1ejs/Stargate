//
//  PushNotification.swift
//  Stargate
//
//  Created by Kyle McAlpine on 18/04/2016.
//
//

import Foundation

public typealias PushNotificationPayload = [NSObject : AnyObject]

private var defaultPushNotificationKey = "notification_id"

@objc public class PushNotification: NSObject, Regexable {
    public let payload: PushNotificationPayload
    
    public init(payload: PushNotificationPayload) {
        self.payload = payload
    }
    
    public static func setDefaultPushNotificationKey(key: String) { defaultPushNotificationKey = key }
    
    public func matchesRegex(regex: Regex) -> Bool {
        if let payload = self.payload["aps"] as? [NSObject : AnyObject], notification = payload[defaultPushNotificationKey] as? String {
            let regex = try? NSRegularExpression(pattern: regex, options: .CaseInsensitive)
            let numberOfMatches = regex?.numberOfMatchesInString(notification, options: [], range: NSMakeRange(0, notification.characters.count))
            return numberOfMatches > 0
        }
        return false
    }
}

@objc public protocol PushNotificationCatcher: class {
    func catchPushNotification(notification: PushNotification)
}

public typealias PushNotificationClosure = (notification: PushNotification) -> ()
public class PushNotificationClosureCatcher: PushNotificationCatcher {
    public let callback: PushNotificationClosure
    public init(callback: PushNotificationClosure) { self.callback = callback }
    @objc public func catchPushNotification(notification: PushNotification) { self.callback(notification: notification) }
}
