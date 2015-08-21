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

public protocol RouterDelegate: class {
    func catchDeepLink(params: DeepLinkParams) -> Bool
    func catchNotification(userInfo: NotificationParams)
}

private var routes = [RouteRegex : Route]()
private weak var delegate: RouterDelegate?
private var notificationKey = "notification_id"

public class Router {
    public static func setRoute(route: Route) {
        routes[route.regex] = route
    }
    
    public static func unsetRoute(route: Route) {
        unsetRoute(route.regex)
    }
    
    public static func unsetRoute(routeRegex: RouteRegex) {
        routes[routeRegex] = nil
    }
    
    public static func callbackForRoute(regex: RouteRegex) -> Route? {
        return routes[regex]
    }
    
    public static func setNotificationKey(key: String) {
        notificationKey = key
    }
    
    public static func handleDeepLink(params: DeepLinkParams) -> Bool {
        if let host = params.url.host, path = params.url.path {
            let link = "\(host)\(path)"
            for route in routes.values {
                switch route.callback {
                case let .DeepLink(callback):
                    let regex = NSRegularExpression(pattern: route.regex, options: .CaseInsensitive, error: nil)
                    if regex?.numberOfMatchesInString(link, options: nil, range: NSMakeRange(0, count(link))) > 0 {
                        return callback(params)
                    }
                default:
                    break
                }
            }
            return delegate?.catchDeepLink(params) ?? false
        }
        return false
    }
    
    public static func handleNotification(userInfo: NotificationParams) {
        if let payload = userInfo["aps"] as? [NSObject : AnyObject], notification = payload[notificationKey] as? String {
            for route in routes.values {
                switch route.callback {
                case let .Notification(callback):
                    let regex = NSRegularExpression(pattern: route.regex, options: .CaseInsensitive, error: nil)
                    if regex?.numberOfMatchesInString(notification, options: nil, range: NSMakeRange(0, count(notification))) > 0 {
                        return callback(userInfo)
                    }
                default:
                    break
                }
            }
        }
        delegate?.catchNotification(userInfo)
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
    public init(regex: RouteRegex, callback: RouteCallback) {
        self.regex = regex
        self.callback = callback
    }
}
