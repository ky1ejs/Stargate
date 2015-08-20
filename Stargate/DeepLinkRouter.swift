//
//  DeepLinkRouter.swift
//
//  Created by Kyle McAlpine and Daniel Tomlinson on 28/06/2015.
//  Copyright (c) Kyle McAlpine and Daniel Tomlinson. All rights reserved.
//

import UIKit

public typealias DeepLinkParams = (url: NSURL, sourceApplication: String?, annotation: AnyObject?)
public typealias DeepLinkCallback = DeepLinkParams -> Bool
public typealias NotificationParams = [String : AnyObject]
public typealias NotificationCallback = (NotificationParams) -> ()

public protocol DeepLinkRouterDelegate: class {
    func catchDeepLink(params: DeepLinkParams) -> Bool
    func catchNotification(params: NotificationParams)
}

private var routes = [RouteRegex : Route]()
private weak var delegate : DeepLinkRouterDelegate?

public class DeepLinkRouter {
    public static func setRoute(route: Route) {
        routes[route.regex] = route
    }
    
    public static func unsetRoute(route: Route) {
        routes[route.regex] = nil
    }
    
    public static func callbackForRoute(regex: RouteRegex) -> Route? {
        return routes[regex]
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
    
    public static func handleNotification(userInfo: [String : AnyObject]) {
        if let notification = userInfo["Notifications"] as? String {
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
