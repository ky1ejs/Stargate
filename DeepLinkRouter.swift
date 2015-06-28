//
//  DeepLinkRouter.swift
//
//  Created by Kyle McAlpine on 28/06/2015.
//

import UIKit

typealias DeepLinkParams = (url: NSURL, sourceApplication: String?, annotation: AnyObject?)
typealias RouterCallback = DeepLinkParams -> Bool

protocol DeepLinkRouterDelegate {
    func catchDeepLink(DeepLinkParams) -> Bool
}

private var callbacks = [String : RouterCallback]()
private var delegate : DeepLinkRouterDelegate?

class DeepLinkRouter {
    static func setCallback(callback: RouterCallback?, forRoute route: String) {
        callbacks[route] = callback
    }
    
    static func callbackForRoute(route: String) -> RouterCallback? {
        return callbacks[route]
    }
    
    static func handleDeepLink(params: DeepLinkParams) -> Bool {
        if let host = params.url.host, path = params.url.path {
            let router = "\(host)\(path)"
            let callback = callbacks[router]
            return (callbacks[router]?(params) ?? delegate?.catchDeepLink(params) ?? false)
        }
        return false
    }
    
}