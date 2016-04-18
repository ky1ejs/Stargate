//
//  Router.swift
//  Stargate
//
//  Created by Kyle McAlpine on 18/04/2016.
//
//

import Foundation


public protocol RouterDelegate: DeepLinkCatcher, PushNotificationCatcher {}

public typealias Regex = String

public protocol Regexable {
    func matchesRegex(regex: Regex) -> Bool
}

private var deepLinkRoutes = NSMapTable()
private var pushNotificationRoutes = NSMapTable()

public struct Router {}

public extension Router {
    public static weak var delegate: RouterDelegate?
    public static func setDeepLinkCatcher(catcher: DeepLinkCatcher, forRegex regex: Regex) { deepLinkRoutes.setObject(catcher, forKey: regex) }
    public static func deepLinkCatcherForRegex(regex: Regex) -> DeepLinkCatcher? { return deepLinkRoutes.objectForKey(regex) as? DeepLinkCatcher }
    public static func unsetDeepLinkCatcherForRegex(regex: Regex) { deepLinkRoutes.removeObjectForKey(regex) }
    
    public static func handleDeepLink(deepLink: DeepLink) -> Bool {
        let deepLinkRoutesDict = deepLinkRoutes.dictionaryRepresentation() as! [Regex : DeepLinkCatcher]
        for (key, value) in deepLinkRoutesDict {
            if deepLink.matchesRegex(key) && value.catchDeepLink(deepLink) {
                return true
            }
        }
        return self.delegate?.catchDeepLink(deepLink) ?? false
    }
}

public extension Router {
    public static func setPushNotificationCatcher(catcher: PushNotificationCatcher, forRegex regex: Regex) { pushNotificationRoutes.setObject(catcher, forKey: regex) }
    public static func pushNotificationCatcherForRegex(regex: Regex) -> PushNotificationCatcher? { return pushNotificationRoutes.objectForKey(regex) as? PushNotificationCatcher }
    public static func unsetPushNotificationCatcherForRegex(regex: Regex) { pushNotificationRoutes.removeObjectForKey(regex) }
    
    public static func handleNotification(userInfo: PushNotificationPayload) {
        let pushNotificationRoutesDict = pushNotificationRoutes.dictionaryRepresentation() as! [Regex : PushNotificationCatcher]
        let notification = PushNotification(payload: userInfo)
        for (key, value) in pushNotificationRoutesDict {
            if notification.matchesRegex(key) {
                value.catchPushNotification(notification)
            }
        }
        self.delegate?.catchPushNotification(notification)
    }
}
