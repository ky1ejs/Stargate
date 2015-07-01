//
//  DeepLinkRouter.swift
//
//  Created by Kyle McAlpine and Daniel Tomlinson on 28/06/2015.
//

import UIKit

public typealias DeepLinkParams = (url: NSURL, sourceApplication: String?, annotation: AnyObject?)
public typealias RouterCallback = DeepLinkParams -> Bool

public protocol DeepLinkRouterDelegate : class {
     func catchDeepLink(DeepLinkParams) -> Bool
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
                var error : NSError?
                let regex = NSRegularExpression(pattern: route.regex, options: .CaseInsensitive, error: &error)
                if regex?.numberOfMatchesInString(link, options: nil, range: NSMakeRange(0, count(link))) > 0 {
                    return route.callback(params)
                }
            }
            return delegate?.catchDeepLink(params) ?? false
        }
        return false
    }
    
}
