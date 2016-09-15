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
        } catch LayoutError.MissingViewPosition(let message) {
            layout.handleLayoutError(message)
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
