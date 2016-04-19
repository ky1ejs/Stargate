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
        let regex = "^https:\\/\\/loot.io\\/verify-waiting-list-email"
        let deepLinkClosure = DeepLinkClosureCatcher(callback: { (params) -> Bool in return true })
        Router.setDeepLinkCatcher(deepLinkClosure, forRegex: regex, referenceStrength: .Strong)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let url = NSURL(string: "https://loot.io/verify-waiting-list-email")!
        let called = Router.handleDeepLink(DeepLink(url: url, sourceApplication: nil, annotation: NSObject()))
        XCTAssertTrue(called)
    }
}
