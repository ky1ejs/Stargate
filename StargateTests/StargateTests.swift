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
        Router.setRoute(Route(regex: regex, callback: .DeepLinkClosure({ (params) -> Bool in return true })))
        let url = NSURL(string: "https://loot.io/verify-waiting-list-email")!
        let called = Router.handleDeepLink(DeepLinkParams(url: url, sourceApplication: nil, annotation: NSObject()))
        XCTAssertTrue(called)
    }
    
    func testCustomSchemeDeepLink() {
        let regex = "^loot://confirm-password-reset-email\\/.*$"
        Router.setRoute(Route(regex: regex, callback: .DeepLinkClosure({ (params) -> Bool in return true })))
        let url = NSURL(string: "loot://confirm-password-reset-email/?token=onjk321dash09832gadjdhdh203223ih2io22k")!
        let called = Router.handleDeepLink(DeepLinkParams(url: url, sourceApplication: nil, annotation: NSObject()))
        XCTAssertTrue(called)
    }
}
