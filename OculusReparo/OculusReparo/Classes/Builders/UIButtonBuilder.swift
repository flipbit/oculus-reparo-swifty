//
//  ButtonBuilder.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class UIButtonBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "button"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let button: UIButton = try initialize(layout, instance: instance, parent: parent)
        
        // Font
        let size = layout.getCGFloat("font-size", ifMissing: 17)
        let weight = try Convert.getFontWeight(layout.getValue("font-weight"))
        button.titleLabel?.font = UIFont.systemFontOfSize(size, weight: weight)
        
        if let title = layout.getValue("title") {
            button.setTitle(title, forState: UIControlState.Normal)
        }

        if let bundle = layout.getValue("image-bundle") {
            if let image = UIImage(named: bundle)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate) {
                button.setImage(image, forState: UIControlState.Normal)
            }
        }
        
        if let color = try layout.getUIColor("tint-color") {
            button.setTitleColor(color, forState: UIControlState.Normal)
            button.tintColor = color
        }
        
        if let touched = layout.getValue("touched"), eventTarget = instance.eventTarget {
            button.addTarget(eventTarget, action: Selector(touched), forControlEvents: UIControlEvents.TouchUpInside)
            button.addTarget(eventTarget, action: Selector(touched), forControlEvents: UIControlEvents.TouchUpOutside)
        }
        
        if let insets = try Convert.getEdgeInsets(layout.getValue("title-edge-insets")) {
            button.titleEdgeInsets = insets
        }
        
        if let align = layout.getValue("align") {
            switch align {
            case "left":
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            default:
                break;
            }
        }
        
        return button;
    }
}
