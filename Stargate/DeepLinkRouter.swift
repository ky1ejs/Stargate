//
//  DeepLinkRouter.swift
//
//  Created by Kyle McAlpine and Daniel Tomlinson on 28/06/2015.
//

import UIKit

typealias DeepLinkParams = (url: NSURL, sourceApplication: String?, annotation: AnyObject?)
typealias RouterCallback = DeepLinkParams -> Bool

protocol DeepLinkRouterDelegate : class {
    func catchDeepLink(DeepLinkParams) -> Bool
}

private var routes = [RouteRegex : Route]()
private weak var delegate : DeepLinkRouterDelegate?

class DeepLinkRouter {
    static func setRoute(route: Route) {
        routes[route.regex] = route
    }
    
    static func unsetRoute(route: Route) {
        routes[route.regex] = nil
    }
    
    static func callbackForRoute(regex: RouteRegex) -> Route? {
        return routes[regex]
    }
    
    static func handleDeepLink(params: DeepLinkParams) -> Bool {
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
