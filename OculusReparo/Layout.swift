//
//  OculusReparo.swift
//  OculusReparo
//
//  Created by Chris on 06/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation
import UIKit

public class Layout {
    static var builders: [BuilderProtocol] = []
    static private var initialized = false

    public var views: [String: UIView]
    public var variables: [String: String]
    public var directives: [String]
    public var model: NSObject?
    public var eventTarget: AnyObject?
    public var view: UIView?
    public var filename: String?
    
    init() {
        variables = [:]
        directives = []
        views = [:]
        
        // append default builders
        if !Layout.initialized {
            Layout.builders.append(UIViewBuilder())
            Layout.builders.append(UILabelBuilder())
            Layout.builders.append(UISliderBuilder())
            Layout.builders.append(UIButtonBuilder())
            Layout.builders.append(UIImageViewBuilder())
            Layout.builders.append(UITableViewBuilder())
            Layout.builders.append(UIScrollViewBuilder())
            Layout.initialized = true
        }
        
        // append default directives
        directives.append("device:" + Hardware.device.rawValue)
        directives.append("device-type:" + Hardware.deviceType.rawValue)
        directives.append("screen:" + Hardware.screenSize.rawValue)
        directives.append(Hardware.orientation)
    }

    convenience init(filename: String, view: UIView) {
        self.init()
        
        self.view = view
        self.eventTarget = view
        self.filename = filename
    }
    
    convenience init(filename: String, controller: UIViewController) {
        self.init()
        
        self.view = controller.view
        self.eventTarget = controller
        self.filename = filename
    }
    
    convenience init(filename: String) {
        self.init()
        
        self.filename = filename
    }

    public func apply() throws {
        try apply(filename!)
    }
    
    public func apply(filename: String) throws {
        guard let view = view else {
            throw LayoutError.MissingRootView
        }
        
        self.filename = filename
        
        let parser = Parser()
        parser.directives = directives
        parser.variables = variables
        
        let layout = try parser.parseFile(filename)
        
        debug(layout)
        
        try setProperties(layout, view: view)
        
        for section in layout.sections {
            try build(section, parent: view)
        }
    }
    
    func debug(layout: Document) {
        let lines = layout.toString().componentsSeparatedByString("\n")
        
        print("")
        print("Layout: \(lines.count) lines.")
        print("")
        print("----------")
        

        for line in lines {
            print(line)
        }
        
        print("")
        print("----------")
        print("")
    }
    
    /*
    public func animateIn(filename: String, state: ViewState) throws -> ViewState {
        let parser = Reparo.Parser()
        parser.directives = state.directives
        let layout = try parser.parseFile(filename)
        
        try animateIn(layout.sections, state: state)
        
        return state
    }
    
    private func animateIn(layout: [Reparo.Section], state: ViewState) throws -> ViewState {
        for section in layout {
            if let view = state.findView(section) {
                Animation().animateIn(section, view: view)
            }
            
            try animateIn(section.sections, state: state)
        }
        
        return state
    }
    */
    
    public func clearDirective(directive: String) {
        let index = directives.indexOf(directive)
        if let index = index {
            directives.removeAtIndex(index)
        }
    }

    public func clearVariable(name: String) {
        let index = variables.indexForKey(name)
        if let index = index {
            variables.removeAtIndex(index)
        }
    }
    
    public func addVariable(name: String, value: String) {
        variables[name] = value
    }
    
    public func addVariable(name: String, value: UIColor) {
        variables[name] = Convert.getHexColor(value)
    }
    
    public func addVariable(name: String, value: Int) {
        variables[name] = String(value)
    }
    
    public func addVariable(name: String, value: Float) {
        variables[name] = String(value)
    }
    
    public func findView(viewId: String) -> UIView? {
        if views[viewId] != nil {
            return views[viewId]
        }
        
        return nil
    }
    
    public func hasView(viewId: String) -> Bool {
        return views[viewId] != nil
    }
    
    public func handleLayoutError(message: String) {
        if let view = view {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }

            view.backgroundColor = UIColor.whiteColor()

            let header = UIView()
            header.backgroundColor = UIColor.redColor()
            header.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
            view.addSubview(header)
            
            let title = UILabel()
            title.frame = CGRect(x: 8, y: 30, width: view.frame.width - 16, height: 30)
            title.textColor = UIColor.whiteColor()
            title.backgroundColor = UIColor.redColor()
            title.text = "Error Processing Layout"
            title.font = UIFont.boldSystemFontOfSize(17)
            header.addSubview(title)
            
            let label = UILabel()
            label.frame = CGRect(x: 8, y: 68, width: view.frame.width - 16, height: view.frame.height - 68)
            label.textColor = UIColor.redColor()
            label.backgroundColor = UIColor.whiteColor()
            label.text = message
            label.font = UIFont(name: "Courier", size: 15)
            label.numberOfLines = 100
            label.sizeToFit()
            view.addSubview(label)
        } else {
            print(message)
        }
    }
    
    static public func generateErrorMessage(layout: Section, key: String?) -> String {
        var message = "\n\nError occured at:\n\n"
        
        if let key = layout.key {
            message.appendContentsOf("Section name      : \(key)\n")
        }
        
        if let key = key {
            for line in layout.lines {
                if line.key == key {
                    message.appendContentsOf("Line path         : \(line.path)\n")
                    message.appendContentsOf("Line key          : \(key)\n")
                    
                    if let value = line.value {
                        message.appendContentsOf("Line value        : \(value)\n")
                    }
                    
                    message.appendContentsOf("Filename          : \(line.filename)\n")
                    message.appendContentsOf("Line number       : \(line.lineNumber)\n\n")
                }
            }
        }
        
        return message
    }

    /**
     Registers the given builder
    */
    static public func register(builder: BuilderProtocol) {
        Layout.builders.append(builder)
    }
    
    public func enableAutorotation() {
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector: #selector(rotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    @objc private func rotate() throws {
        clearDirective("landscape")
        clearDirective("portrait")
        directives.append(Hardware.orientation)
        
        if let filename = filename {
            try apply(filename)
        }
    }    
    
    private func setProperties(layout: Section, view: UIView) throws {
        if let properties = layout.getSection("layout") {
            view.backgroundColor = try properties.getUIColor("background-color")
        }
    }
    
    private func build(layout: Section, parent: UIView) throws {
        for builder in Layout.builders {
            if (builder.canBuild(layout)) {
                let view = try builder.build(layout, instance: self, parent: parent)
                
                for section in layout.sections {
                    try build(section, parent: view)
                }
                    
                break
            }
        }
    }
}
