//
//  DeepLinkRouter.swift
//
//  Created by Kyle McAlpine and Daniel Tomlinson on 28/06/2015.
//  Copyright (c) Kyle McAlpine and Daniel Tomlinson. All rights reserved.
//

import UIKit

public typealias DeepLinkParams = (url: NSURL, sourceApplication: String?, annotation: AnyObject)
public typealias DeepLinkCallback = DeepLinkParams -> Bool
public typealias NotificationParams = [NSObject : AnyObject]
public typealias NotificationCallback = (NotificationParams) -> ()

public protocol Regexable {
    func matchesRegex(regex: RouteRegex) -> Bool
}

public struct DeepLink: Regexable {
    public let params: DeepLinkParams
    
    public func matchesRegex(regex: RouteRegex) -> Bool {
        if let host = self.params.url.host, path = self.params.url.path {
            let link = "\(host)\(path)"
            let regex = try? NSRegularExpression(pattern: regex, options: .CaseInsensitive)
            if regex?.numberOfMatchesInString(link, options: [], range: NSMakeRange(0, link.characters.count)) > 0 {
                return true
            }
        }
        return false
    }
}

public struct Notification: Regexable {
    public let params: NotificationParams
    
    public func matchesRegex(regex: RouteRegex) -> Bool {
        if let payload = self.params["aps"] as? [NSObject : AnyObject], notification = payload[notificationKey] as? String {
            let regex = try? NSRegularExpression(pattern: regex, options: .CaseInsensitive)
            if regex?.numberOfMatchesInString(notification, options: [], range: NSMakeRange(0, notification.characters.count)) > 0 {
                return true
            }
        }
        return false
    }
}

public protocol DeepLinkCatcher: class {
    func catchDeepLink(deepLink: DeepLink) -> Bool
}

public protocol NotificationCatcher: class {
    func catchNotification(notification: Notification)
}

public protocol RouterDelegate: DeepLinkCatcher, NotificationCatcher {}

private var routes = [RouteRegex : Route]()
private var notificationKey = "notification_id"

public class Router {
    public static weak var delegate: RouterDelegate?
    
    public static func setRoute(route: Route) { routes[route.regex] = route }
    
    public static func unsetRoute(route: Route) { unsetRoute(route.regex) }
    
    public static func unsetRoute(routeRegex: RouteRegex) { routes[routeRegex] = nil }
    
    public static func callbackForRoute(regex: RouteRegex) -> Route? { return routes[regex] }
    
    public static func setNotificationKey(key: String) { notificationKey = key }
    
    public static func handleDeepLink(params: DeepLinkParams) -> Bool {
        let deepLink = DeepLink(params: params)
        for route in routes.values {
            if case  .DeepLinkClosure(let callback) = route.callback where deepLink.matchesRegex(route.regex) && callback(params) {
                return true
            } else if case .DeepLinkCatcher(let weakCatcher) = route.callback where deepLink.matchesRegex(route.regex) && weakCatcher.catcher?.catchDeepLink(deepLink) == true {
                return true
            }
        }
        return self.delegate?.catchDeepLink(deepLink) ?? false
    }
    
    public static func handleNotification(userInfo: NotificationParams) {
        let notification = Notification(params: userInfo)
        for route in routes.values {
            if notification.matchesRegex(route.regex) {
                if case .NotificationClosure(let callback) = route.callback where notification.matchesRegex(route.regex) {
                    callback(userInfo)
                    return
                } else if case .NotificationCatcher(let weakCatcher) = route.callback, let catcher = weakCatcher.catcher {
                    catcher.catchNotification(notification)
                    return
                }
            }
        }
        self.delegate?.catchNotification(notification)
    }
}


public typealias RouteRegex = String

public struct WeakDeepLinkCatcher {
    weak var catcher: DeepLinkCatcher?
    public init(catcher: DeepLinkCatcher) { self.catcher = catcher }
}

public struct WeakNotificationCatcher {
    weak var catcher: NotificationCatcher?
    public init(catcher: NotificationCatcher) { self.catcher = catcher }
}

public enum RouteCallback {
    case DeepLinkCatcher(WeakDeepLinkCatcher)
    case DeepLinkClosure(DeepLinkCallback)
    case NotificationCatcher(WeakNotificationCatcher)
    case NotificationClosure(NotificationCallback)
}

public struct Route {
    let regex: RouteRegex
    let callback: RouteCallback
    
    // Annoyingly, this init has to be here to explicitly make it public
    public init(regex: RouteRegex, callback: RouteCallback) {
        self.regex = regex
        self.callback = callback
    }
}
