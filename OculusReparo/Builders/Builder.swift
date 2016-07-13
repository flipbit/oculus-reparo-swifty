//
//  Builder.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

extension OculusReparo {
    public class Builder {
        public func initialize<T: UIView>(layout: Reparo.Section, state: ViewState, parent: UIView) throws -> T {
            var view: T
            
            if state.hasView(layout) {
                view = state.findView(layout) as! T
            } else {
                view = T()
                state.views[layout.path] = view
                
                if let id = layout.getValue("id") {
                    state.model?.setValue(view, forKey: id)
                }
            }
            
            view.frame = try getFrame(layout, parent: parent)
            view.backgroundColor = try layout.getUIColor("background-color")
            view.layer.zPosition = layout.getCGFloat("z-position", ifMissing: 0)
            view.layer.cornerRadius = layout.getCGFloat("corner-radius", ifMissing: 0)
            view.layer.borderColor = try layout.getCGColor("border-color")
            view.layer.borderWidth = layout.getCGFloat("border-width", ifMissing: 0)
            view.layer.opacity = layout.getFloat("opacity", ifMissing: 1)
            
            if view.superview == nil {
                parent.addSubview(view)
            }
            
            return view
        }
        
        public func getFrame(layout: Reparo.Section, parent: UIView) throws -> CGRect {
            let config = layout.getSection("position")
            
            if config == nil {
                throw OculusReparoError.MissingViewPosition("[\(layout.key) is missing a Position section (line: \(layout.lineNumber))")
            }
            
            let position = Position(section: config!, parent: parent)
            
            return position.toFrame()
        }        
    }
}