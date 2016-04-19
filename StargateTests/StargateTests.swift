//
//  StargateTests.swift
//  StargateTests
//
//  Created by Kyle McAlpine on 18/04/2016.
//
//

import XCTest
@testable import Stargate

class StargateTests: XCTestCase {
    func testHTTPURLRouteDeepLink() {
        let regex = "^https:\\/\\/loot.io\\/verify-waiting-list-email"
        let deepLinkClosure = DeepLinkClosureCatcher(callback: { (params) -> Bool in return true })
        Router.setDeepLinkCatcher(deepLinkClosure, forRegex: regex, referenceStrength: .Weak)
        let url = NSURL(string: "https://loot.io/verify-waiting-list-email")!
        let called = Router.handleDeepLink(DeepLink(url: url, sourceApplication: nil, annotation: NSObject()))
        XCTAssertTrue(called)
        Router.unsetDeepLinkCatcherForRegex(regex)
    }
    
    func testCustomSchemeDeepLink() {
        let regex = "^loot://confirm-password-reset-email\\/.*$"
        let deepLinkClosure = DeepLinkClosureCatcher(callback: { (params) -> Bool in return true })
        Router.setDeepLinkCatcher(deepLinkClosure, forRegex: regex, referenceStrength: .Weak)
        let url = NSURL(string: "loot://confirm-password-reset-email/?token=onjk321dash09832gadjdhdh203223ih2io22k")!
        let called = Router.handleDeepLink(DeepLink(url: url, sourceApplication: nil, annotation: NSObject()))
        XCTAssertTrue(called)
        Router.unsetDeepLinkCatcherForRegex(regex)
    }
}
