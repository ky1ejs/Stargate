//
//  DeepLink.swift
//  Stargate
//
//  Created by Kyle McAlpine on 18/04/2016.
//
//

import Foundation

@objc public class DeepLink: NSObject, Regexable {
    let url: NSURL
    let sourceApplication: String?
    let annotation: AnyObject
    
    init(url: NSURL, sourceApplication: String?, annotation: AnyObject) {
        self.url = url
        self.sourceApplication = sourceApplication
        self.annotation = annotation
    }
    
    public func matchesRegex(regex: Regex) -> Bool {
        let link = self.url.absoluteString
        let regex = try? NSRegularExpression(pattern: regex, options: .CaseInsensitive)
        let numberOfMatches = regex?.numberOfMatchesInString(link, options: [], range: NSMakeRange(0, link.characters.count))
        return numberOfMatches > 0
    }
}

@objc public protocol DeepLinkCatcher: class {
    func catchDeepLink(deepLink: DeepLink) -> Bool
}

public typealias DeepLinkClosure = DeepLink -> Bool
public class DeepLinkClosureCallable: DeepLinkCatcher {
    public let callback: DeepLinkClosure
    public init(callback: DeepLinkClosure) { self.callback = callback }
    @objc public func catchDeepLink(deepLink: DeepLink) -> Bool { return self.callback(deepLink) }
}

public class DeepLinkCatcherCallable: DeepLinkCatcher {
    private(set) weak var catcher: DeepLinkCatcher?
    @objc public func catchDeepLink(deepLink: DeepLink) -> Bool { return self.catcher?.catchDeepLink(deepLink) ?? false }
}