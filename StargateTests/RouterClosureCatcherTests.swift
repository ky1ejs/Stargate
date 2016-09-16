//
//  RouterClosureCatcherTests.swift
//  Stargate
//
//  Created by Kyle McAlpine on 19/04/2016.
//
//

import XCTest
@testable import Stargate

class RouterClosureCatcherTests: XCTestCase {
    override func setUp() {
        super.setUp()
        let strongRegex = "^https:\\/\\/kylejm.io\\/strong"
        let strongDeepLinkClosure = DeepLinkClosureCatcher(callback: { (params) -> Bool in return true })
        Router.setDeepLinkCatcher(strongDeepLinkClosure, forRegex: strongRegex, referenceStrength: .strong)
        
        let weakRegex = "^https:\\/\\/kylejm.io\\/weak"
        let weakDeepLinkClosure = DeepLinkClosureCatcher(callback: { (params) -> Bool in return true })
        Router.setDeepLinkCatcher(weakDeepLinkClosure, forRegex: weakRegex, referenceStrength: .weak)
    }
    
    func testStrongReferrence() {
        let url = URL(string: "https://kylejm.io/strong")!
        let called = Router.handleDeepLink(DeepLink(url: url, sourceApplication: nil, annotation: NSObject()))
        XCTAssertTrue(called)
    }
    
    func testWeakReference() {
        let url = URL(string: "https://kylejm.io/weak")!
        let called = Router.handleDeepLink(DeepLink(url: url, sourceApplication: nil, annotation: NSObject()))
        XCTAssertFalse(called)
    }
}
