//
//  PushNotification.swift
//  Stargate
//
//  Created by Kyle McAlpine on 18/04/2016.
//
//

import Foundation

public typealias PushNotificationPayload = [AnyHashable: Any]

private var defaultPushNotificationKey = "notification_id"

@objc public class PushNotification: NSObject, Regexable {
    public let payload: PushNotificationPayload
    
    public init(payload: PushNotificationPayload) {
        self.payload = payload
    }
    
    public static func setDefaultPushNotificationKey(_ key: String) { defaultPushNotificationKey = key }
    
    public func matchesRegex(_ regex: Regex) -> Bool {
        if let payload = self.payload["aps"] as? [AnyHashable: Any], let notification = payload[defaultPushNotificationKey] as? String {
            let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive)
            guard let numberOfMatches = regex?.numberOfMatches(in: notification, options: [], range: NSMakeRange(0, notification.characters.count)) else { return false }
            return numberOfMatches > 0
        }
        return false
    }
}

public protocol PushNotificationCatcher: class {
    func catchPushNotification(_ notification: PushNotification)
}

public typealias PushNotificationClosure = (_ notification: PushNotification) -> ()
public class PushNotificationClosureCatcher: PushNotificationCatcher {
    public let callback: PushNotificationClosure
    public init(callback: @escaping PushNotificationClosure) { self.callback = callback }
    public func catchPushNotification(_ notification: PushNotification) { self.callback(notification) }
}
