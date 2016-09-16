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
        let regex = "^https:\\/\\/kylejm.io\\/action"
        let deepLinkClosure = DeepLinkClosureCatcher(callback: { (params) -> Bool in return true })
        Router.setDeepLinkCatcher(deepLinkClosure, forRegex: regex, referenceStrength: .weak)
        let url = URL(string: "https://kylejm.io/action")!
        let called = Router.handleDeepLink(DeepLink(url: url, sourceApplication: nil, annotation: NSObject()))
        XCTAssertTrue(called)
        Router.unsetDeepLinkCatcherForRegex(regex)
    }
    
    func testCustomSchemeDeepLink() {
        let regex = "^kylejm://action\\/.*$"
        let deepLinkClosure = DeepLinkClosureCatcher(callback: { (params) -> Bool in return true })
        Router.setDeepLinkCatcher(deepLinkClosure, forRegex: regex, referenceStrength: .weak)
        let url = URL(string: "kylejm://action/?token=onjk321dash09832gadjdhdh203223ih2io22k")!
        let called = Router.handleDeepLink(DeepLink(url: url, sourceApplication: nil, annotation: NSObject()))
        XCTAssertTrue(called)
        Router.unsetDeepLinkCatcherForRegex(regex)
    }
}
