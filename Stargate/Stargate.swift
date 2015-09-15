//
//  DeepLinkRouter.swift
//
//  Created by Kyle McAlpine and Daniel Tomlinson on 28/06/2015.
//  Copyright (c) Kyle McAlpine and Daniel Tomlinson. All rights reserved.
//

import UIKit

public typealias DeepLinkParams = (url: NSURL, sourceApplication: String?, annotation: AnyObject?)
public typealias DeepLinkCallback = DeepLinkParams -> Bool
public typealias NotificationParams = [NSObject : AnyObject]
public typealias NotificationCallback = (NotificationParams) -> ()

public protocol Regexable {
    func matchesRegex(regex: RouteRegex) -> Bool
}

public struct DeepLink: Regexable {
    let params: DeepLinkParams
    
    public func matchesRegex(regex: RouteRegex) -> Bool {
        if let host = self.params.url.host, path = self.params.url.path {
            let link = "\(host)\(path)"
            let regex = NSRegularExpression(pattern: regex, options: .CaseInsensitive, error: nil)
            if regex?.numberOfMatchesInString(link, options: nil, range: NSMakeRange(0, count(link))) > 0 {
                return true
            }
        }
        return false
    }
}

public struct Notification: Regexable {
    let params: NotificationParams
    
    public func matchesRegex(regex: RouteRegex) -> Bool {
        if let payload = self.params["aps"] as? [NSObject : AnyObject], notification = payload[notificationKey] as? String {
            let regex = NSRegularExpression(pattern: regex, options: .CaseInsensitive, error: nil)
            if regex?.numberOfMatchesInString(notification, options: nil, range: NSMakeRange(0, count(notification))) > 0 {
                return true
            }
        }
        return false
    }
}

public protocol RouterDelegate: class {
    func catchDeepLink(deepLink: DeepLink) -> Bool
    func catchNotification(notification: Notification)
}

private var routes = [RouteRegex : Route]()
private weak var delegate: RouterDelegate?
private var notificationKey = "notification_id"

public class Router {
    public static func setRoute(route: Route) { routes[route.regex] = route }
    
    public static func unsetRoute(route: Route) { unsetRoute(route.regex) }
    
    public static func unsetRoute(routeRegex: RouteRegex) { routes[routeRegex] = nil }
    
    public static func callbackForRoute(regex: RouteRegex) -> Route? { return routes[regex] }
    
    public static func setNotificationKey(key: String) { notificationKey = key }
    
    public static func handleDeepLink(params: DeepLinkParams) -> Bool {
        let deepLink = DeepLink(params: params)
        for route in routes.values {
            switch route.callback {
            case let .DeepLink(callback):
                if deepLink.matchesRegex(route.regex) {
                    return callback(params)
                }
            default:
                break
            }
        }
        return delegate?.catchDeepLink(deepLink) ?? false
    }
    
    public static func handleNotification(userInfo: NotificationParams) {
        let notification = Notification(params: userInfo)
        for route in routes.values {
            switch route.callback {
            case let .Notification(callback):
                if notification.matchesRegex(route.regex) {
                    callback(userInfo)
                    return
                }
            default:
                break
            }
        }
        delegate?.catchNotification(notification)
    }
}


public typealias RouteRegex = String

public enum RouteCallback {
    case DeepLink(DeepLinkCallback)
    case Notification(NotificationCallback)
}

public struct Route {
    let regex : RouteRegex
    let callback : RouteCallback
    
    // Annoyingly, this init has to be here to explicitly make it public
    public init(regex: RouteRegex, callback: RouteCallback) {
        self.regex = regex
        self.callback = callback
    }
}
