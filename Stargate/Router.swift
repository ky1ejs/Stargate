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

private var weakDeepLinkRoutes = NSMapTable.strongToWeakObjectsMapTable()
private var strongDeepLinkRoutes = NSMapTable.strongToStrongObjectsMapTable()
private var weakPushNotificationRoutes = NSMapTable.strongToWeakObjectsMapTable()
private var strongPushNotificationRoutes = NSMapTable.strongToStrongObjectsMapTable()

enum RouteType {
    case DeepLink
    case PushNotification
}

public enum ReferenceStrength {
    case Strong
    case Weak
    
    var opposite: ReferenceStrength {
        switch self {
        case .Strong:   return .Weak
        case .Weak:     return .Strong
        }
    }
    
    func routesForType(type: RouteType) -> NSMapTable {
        switch (self, type) {
        case (.Strong, .DeepLink):          return strongDeepLinkRoutes
        case (.Weak, .DeepLink):            return weakDeepLinkRoutes
        case (.Strong, .PushNotification):  return strongPushNotificationRoutes
        case (.Weak, .PushNotification):    return weakPushNotificationRoutes
        }
    }
}

public struct Router {}

public extension Router {
    public static weak var delegate: RouterDelegate?
    
    public static func setDeepLinkCatcher(catcher: DeepLinkCatcher, forRegex regex: Regex, referenceStrength: ReferenceStrength) {
        referenceStrength.opposite.routesForType(.DeepLink).removeObjectForKey(regex)
        referenceStrength.routesForType(.DeepLink).setObject(catcher, forKey: regex)
    }
    
    public static func deepLinkCatcherForRegex(regex: Regex) -> DeepLinkCatcher? {
        let strongCatcher = strongDeepLinkRoutes.objectForKey(regex) as? DeepLinkCatcher
        let weakCatcher = weakDeepLinkRoutes.objectForKey(regex) as? DeepLinkCatcher
        return strongCatcher ?? weakCatcher
    }
    
    public static func unsetDeepLinkCatcherForRegex(regex: Regex) {
        strongDeepLinkRoutes.removeObjectForKey(regex)
        weakDeepLinkRoutes.removeObjectForKey(regex)
    }
    
    public static func handleDeepLink(deepLink: DeepLink) -> Bool {
        let strongRoutes = strongDeepLinkRoutes.dictionaryRepresentation() as! [Regex : DeepLinkCatcher]
        let weakRoutes = weakDeepLinkRoutes.dictionaryRepresentation() as! [Regex : DeepLinkCatcher]
        for (key, value) in strongRoutes + weakRoutes {
            if deepLink.matchesRegex(key) && value.catchDeepLink(deepLink) {
                return true
            }
        }
        return self.delegate?.catchDeepLink(deepLink) ?? false
    }
}

public extension Router {
    public static func setPushNotificationCatcher(catcher: PushNotificationCatcher, forRegex regex: Regex, referenceStrength: ReferenceStrength) {
        referenceStrength.opposite.routesForType(.PushNotification).removeObjectForKey(regex)
        referenceStrength.routesForType(.PushNotification).setObject(catcher, forKey: regex)
    }
    
    public static func pushNotificationCatcherForRegex(regex: Regex) -> PushNotificationCatcher? {
        let strongCatcher = strongPushNotificationRoutes.objectForKey(regex) as? PushNotificationCatcher
        let weakCatcher = weakPushNotificationRoutes.objectForKey(regex) as? PushNotificationCatcher
        return strongCatcher ?? weakCatcher
    }
    
    public static func removePushNotificationCatcherForRegex(regex: Regex) {
        strongPushNotificationRoutes.removeObjectForKey(regex)
        weakPushNotificationRoutes.removeObjectForKey(regex)
    }
    
    public static func handleNotification(userInfo: PushNotificationPayload) {
        let notification = PushNotification(payload: userInfo)
        let strongCatchers = strongPushNotificationRoutes.dictionaryRepresentation() as! [Regex : PushNotificationCatcher]
        let weakCatchers = weakPushNotificationRoutes.dictionaryRepresentation() as! [Regex : PushNotificationCatcher]
        for (key, value) in strongCatchers + weakCatchers {
            if notification.matchesRegex(key) {
                value.catchPushNotification(notification)
            }
        }
        self.delegate?.catchPushNotification(notification)
    }
}
