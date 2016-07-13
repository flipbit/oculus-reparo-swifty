//
//  ViewState.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation
import UIKit

extension OculusReparo {
    
    public class ViewState {
        var views: [String: UIView]
        var variables: [String: String]
        var directives: [String]
        var model: NSObject?
        var eventTarget: AnyObject?
        var view: UIView
        
        init(view: UIView) {
            variables = [:]
            directives = []
            views = [:]
            self.view = view
            
            // append default directives
            directives.append("device:" + Hardware.device.rawValue)
            directives.append("device-type:" + Hardware.deviceType.rawValue)
            directives.append("screen:" + Hardware.screenSize.rawValue)
            directives.append(Hardware.orientation)
        }
        
        public func clearDirective(directive: String) {
            let index = directives.indexOf(directive)
            if let index = index {
                directives.removeAtIndex(index)
            }
        }
        
        public func findView(layout: Reparo.Section) -> UIView? {
            if views[layout.path] != nil {
                return views[layout.path]
            }
            
            return nil
        }
        
        public func hasView(layout: Reparo.Section) -> Bool {
            return views[layout.path] != nil
        }
    }

}