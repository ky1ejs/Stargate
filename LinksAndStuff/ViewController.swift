//
//  ViewController.swift
//  LinksAndStuff
//
//  Created by Kyle McAlpine on 15/09/2015.
//
//

import UIKit
import Stargate

class ViewController: UIViewController {
    private let deepLinkRegex = "^link-me$"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Router.setRoute(Route(regex: self.deepLinkRegex, callback: .DeepLink(self.routerCallback)))
    }
    
    deinit {
        Router.unsetRoute(self.deepLinkRegex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func routerCallback(params: DeepLinkParams) -> Bool {
        if self.view.window != nil {
            self.view.backgroundColor = .greenColor()
            return true
        } else {
            return false
        }
    }
}

