//
//  DeepLink.swift
//  Stargate
//
//  Created by Kyle McAlpine on 18/04/2016.
//
//

import Foundation

public class DeepLink: NSObject, Regexable {
    public let url: URL
    public let sourceApplication: String?
    public let annotation: AnyObject
    
    public init(url: URL, sourceApplication: String?, annotation: AnyObject) {
        self.url = url
        self.sourceApplication = sourceApplication
        self.annotation = annotation
    }
    
    public func matchesRegex(_ regex: Regex) -> Bool {
        let link = self.url.absoluteString
        let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive)
        guard let numberOfMatches = regex?.numberOfMatches(in: link, options: [], range: NSMakeRange(0, link.characters.count)) else { return false }
        return numberOfMatches > 0
    }
}

public protocol DeepLinkCatcher: class {
    func catchDeepLink(_ deepLink: DeepLink) -> Bool
}

public typealias DeepLinkClosure = (_ deepLink: DeepLink) -> Bool
public class DeepLinkClosureCatcher: DeepLinkCatcher {
    public let callback: DeepLinkClosure
    public init(callback: @escaping DeepLinkClosure) { self.callback = callback }
    public func catchDeepLink(_ deepLink: DeepLink) -> Bool { return self.callback(deepLink) }
}
