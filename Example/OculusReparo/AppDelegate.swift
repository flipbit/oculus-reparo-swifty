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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Set debugger
        Layout.debugger = ConsoleLayoutDebugger()
        
        return true
    }
}

