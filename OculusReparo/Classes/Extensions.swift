//
//  UIVIewControllerExtension.swift
//  Layout
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//
import Foundation
import UIKit

extension UIViewController {
    /**
     Layouts the view using the given filename
     
     - Parameter filename:   The name of the file containing the view
     
     - Returns:              An Layout instance
     */
    public func createLayout(filename: String) -> Layout {
        let oculus = Layout(filename: filename, controller: self)
        
        return oculus
    }
    
    public func createLayout(filename: String, model: NSObject) -> Layout {
        let oculus = Layout(filename: filename, controller: self)
        
        oculus.model = model        
    
        return oculus
    }
    
    public func createLayout(filename: String, model: NSObject, eventTarget: AnyObject) -> Layout {
        let oculus = Layout(filename: filename, controller: self)
        
        oculus.model = model
        oculus.eventTarget = eventTarget
        
        return oculus
    }
    
    public func applyLayout(layout: Layout) -> Bool {
        return UIView.applyLayout(layout)
    }
}

extension UIView {
    /**
     Layouts the view using the given filename
     
     - Parameter filename:   The name of the file containing the view
     
     - Returns:              An Layout instance
     */
    public func createLayout(filename: String) -> Layout {
        let oculus = Layout(filename: filename, view: self)
        
        return oculus
    }
    
    public func createLayout(filename: String, model: NSObject) -> Layout {
        let oculus = Layout(filename: filename, view: self)
        
        oculus.model = model
        
        return oculus
    }
    
    public func createLayout(filename: String, model: NSObject, eventTarget: AnyObject) -> Layout {
        let oculus = Layout(filename: filename, view: self)
        
        oculus.model = model
        oculus.eventTarget = eventTarget
        
        return oculus
    }

    public func applyLayout(layout: Layout) -> Bool {
        return UIView.applyLayout(layout)
    }
    
    public static func applyLayout(layout: Layout) -> Bool {
        var result = false
        do {
            try layout.apply()
            
            result = true
        } catch LayoutError.MissingRootView {
            layout.handleLayoutError("Controller root view is not set")
        } catch LayoutError.InvalidConfiguration(let message) {
            layout.handleLayoutError(message)
        } catch LayoutError.ConfigurationError(let info) {
            layout.handleLayoutError(info.message)
        } catch LayoutError.MissingModelProperty(let message) {
            layout.handleLayoutError(message)
        } catch ReparoError.InvalidColorString(let message) {
            layout.handleLayoutError(message)
        } catch ReparoError.InvalidConfigurationLine(let message) {
            layout.handleLayoutError(message)
        } catch ReparoError.MissingConfigurationFile(let message) {
            layout.handleLayoutError(message)
        } catch ReparoError.RecursiveIncludeDetected {
            layout.handleLayoutError("Recursive include file detected.")
        } catch let error as NSError {
            layout.handleLayoutError(error.localizedDescription)
        }
        
        return result
    }
    
}

extension CGRect {
    public func add(x x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0) -> CGRect {
        return CGRect(x: self.origin.x + x, y: self.origin.y + y, width: self.width + width, height: self.height + height)
    }
    
    public func resize(x x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil) -> CGRect {
        let x = x ?? self.origin.x
        let y = y ?? self.origin.y
        let h = height ?? self.height
        let w = width ?? self.width
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
