//
//  AppDelegate.swift
//  OculusReparo
//
//  Created by Chris Wood on 07/27/2016.
//  Copyright (c) 2016 Chris Wood. All rights reserved.
//

import UIKit
import OculusReparo

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Set debugger
        Layout.debugger = LayoutDebugger()
        
        return true
    }
}

