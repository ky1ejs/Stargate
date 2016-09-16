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
    func matchesRegex(_ regex: Regex) -> Bool
}

private var weakDeepLinkRoutes = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
private var strongDeepLinkRoutes = NSMapTable<NSString, AnyObject>.strongToStrongObjects()
private var weakPushNotificationRoutes = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
private var strongPushNotificationRoutes = NSMapTable<NSString, AnyObject>.strongToStrongObjects()

enum RouteType {
    case deepLink
    case pushNotification
}

public enum ReferenceStrength {
    case strong
    case weak
    
    var opposite: ReferenceStrength {
        switch self {
        case .strong:   return .weak
        case .weak:     return .strong
        }
    }
    
    func routesForType(_ type: RouteType) -> NSMapTable<NSString, AnyObject> {
        switch (self, type) {
        case (.strong, .deepLink):          return strongDeepLinkRoutes
        case (.weak, .deepLink):            return weakDeepLinkRoutes
        case (.strong, .pushNotification):  return strongPushNotificationRoutes
        case (.weak, .pushNotification):    return weakPushNotificationRoutes
        }
    }
}

public struct Router {}

public extension Router {
    public static weak var delegate: RouterDelegate?
    
    public static func setDeepLinkCatcher(_ catcher: DeepLinkCatcher, forRegex regex: Regex, referenceStrength: ReferenceStrength) {
        referenceStrength.opposite.routesForType(.deepLink).removeObject(forKey: regex as NSString)
        referenceStrength.routesForType(.deepLink).setObject(catcher, forKey: regex as NSString)
    }
    
    public static func deepLinkCatcherForRegex(_ regex: Regex) -> DeepLinkCatcher? {
        let strongCatcher = strongDeepLinkRoutes.object(forKey: regex as NSString) as? DeepLinkCatcher
        let weakCatcher = weakDeepLinkRoutes.object(forKey: regex as NSString) as? DeepLinkCatcher
        return strongCatcher ?? weakCatcher
    }
    
    public static func unsetDeepLinkCatcherForRegex(_ regex: Regex) {
        strongDeepLinkRoutes.removeObject(forKey: regex as NSString)
        weakDeepLinkRoutes.removeObject(forKey: regex as NSString)
    }
    
    public static func handleDeepLink(_ deepLink: DeepLink) -> Bool {
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
    public static func setPushNotificationCatcher(_ catcher: PushNotificationCatcher, forRegex regex: Regex, referenceStrength: ReferenceStrength) {
        referenceStrength.opposite.routesForType(.pushNotification).removeObject(forKey: regex as NSString)
        referenceStrength.routesForType(.pushNotification).setObject(catcher, forKey: regex as NSString)
    }
    
    public static func pushNotificationCatcherForRegex(_ regex: Regex) -> PushNotificationCatcher? {
        let strongCatcher = strongPushNotificationRoutes.object(forKey: regex as NSString) as? PushNotificationCatcher
        let weakCatcher = weakPushNotificationRoutes.object(forKey: regex as NSString) as? PushNotificationCatcher
        return strongCatcher ?? weakCatcher
    }
    
    public static func removePushNotificationCatcherForRegex(_ regex: Regex) {
        strongPushNotificationRoutes.removeObject(forKey: regex as NSString)
        weakPushNotificationRoutes.removeObject(forKey: regex as NSString)
    }
    
    public static func handleNotification(_ userInfo: PushNotificationPayload) {
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
