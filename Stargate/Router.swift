//
//  Router.swift
//  Stargate
//
//  Created by Kyle McAlpine on 18/04/2016.
//
//

import Foundation



public protocol RouterDelegate: DeepLinkCatcher, NotificationCatcher {}

public enum RouteCallback {
    case DeepLink(DeepLinkCatcher)
    case PushNotification(catcher: NotificationCatcher, pushNotificationKey: String?)
}

public typealias Regex = String

public struct Route {
    let regex: Regex
    let callback: RouteCallback
    
    // Annoyingly, this init has to be here to explicitly make it public
    public init(regex: Regex, callback: RouteCallback) {
        self.regex = regex
        self.callback = callback
    }
}

public protocol Routeable {
    func matchesRoute(route: Route) -> Bool
}

private var routes = [Regex : Route]()

public class Router {
    public static weak var delegate: RouterDelegate?
    public static func setRoute(route: Route) { routes[route.regex] = route }
    public static func unsetRoute(route: Route) { unsetRouteForRegex(route.regex) }
    public static func unsetRouteForRegex(regex: Regex) { routes[regex] = nil }
    public static func routeForRegex(regex: Regex) -> Route? { return routes[regex] }
    public static func allRoutes() -> [Route] { return Array(routes.values) }
    
    public static func handleDeepLink(deepLink: DeepLink) -> Bool {
        for route in routes.values {
            if case .DeepLink(let catcher) = route.callback where
                deepLink.matchesRoute(route) && catcher.catchDeepLink(deepLink) {
                return true
            }
        }
        return self.delegate?.catchDeepLink(deepLink) ?? false
    }
    
    public static func handleNotification(userInfo: PushNotificationParams) {
        let notification = PushNotification(params: userInfo)
        for route in routes.values {
            if case let .PushNotification(catcher, _) = route.callback where notification.matchesRoute(route) {
                catcher.catchNotification(notification)
            }
        }
        self.delegate?.catchNotification(notification)
    }
}
