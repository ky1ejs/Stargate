//
//  Route.swift
//  Loot
//
//  Created by Kyle McAlpine on 29/06/2015.
//  Copyright (c) 2015 Loot Financial Services Ltd. All rights reserved.
//

import UIKit

typealias RouteRegex = String
struct Route {
    let regex : RouteRegex
    let callback : RouterCallback
    init(regex: RouteRegex, callback: RouterCallback) {
        self.regex = regex
        self.callback = callback
    }
}
