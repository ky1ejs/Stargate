//
//  DeepLink.swift
//  Stargate
//
//  Created by Kyle McAlpine on 18/04/2016.
//
//

import Foundation

public struct DeepLinkParams {
    let url: NSURL
    let sourceApplication: String?
    let annotation: AnyObject
}

public typealias DeepLinkClosure = DeepLinkParams -> Bool

public struct DeepLink: Routeable {
    public let params: DeepLinkParams
    
    public func matchesRoute(route: Route) -> Bool {
        let link = self.params.url.absoluteString
        let regex = try? NSRegularExpression(pattern: route.regex, options: .CaseInsensitive)
        let numberOfMatches = regex?.numberOfMatchesInString(link, options: [], range: NSMakeRange(0, link.characters.count))
        return numberOfMatches > 0
    }
}

public protocol DeepLinkCatcher: class {
    func catchDeepLink(deepLink: DeepLink) -> Bool
}

public class DeepLinkClosureCallable: DeepLinkCatcher {
    public let callback: DeepLinkClosure
    public init(callback: DeepLinkClosure) { self.callback = callback }
    public func catchDeepLink(deepLink: DeepLink) -> Bool { return self.callback(deepLink.params) }
}

public class DeepLinkCatcherCallable: DeepLinkCatcher {
    private(set) weak var catcher: DeepLinkCatcher?
    public func catchDeepLink(deepLink: DeepLink) -> Bool { return self.catcher?.catchDeepLink(deepLink) ?? false }
}