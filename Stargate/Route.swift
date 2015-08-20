//
//  Route.swift
//  Loot
//
//  Created by Kyle McAlpine and Daniel Tomlinson on 28/06/2015..
//  Copyright (c) Kyle McAlpine and Daniel Tomlinson. All rights reserved.
//

import Foundation

public typealias RouteRegex = String

public enum RouteCallback {
    case DeepLink(DeepLinkCallback)
    case Notification(NotificationCallback)
}

public struct Route {
    let regex : RouteRegex
    let callback : RouteCallback
    public init(regex: RouteRegex, callback: RouteCallback) {
        self.regex = regex
        self.callback = callback
    }
}
