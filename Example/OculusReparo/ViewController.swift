//
//  ViewController.swift
//  OculusReparo
//
//  Created by Chris Wood on 07/27/2016.
//  Copyright (c) 2016 Chris Wood. All rights reserved.
//

import UIKit
import OculusReparo

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let layout = Layout(filename: "Basic.layout", controller: self)
        
        try! layout.apply()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

