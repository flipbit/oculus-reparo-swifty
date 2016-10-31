//
//  ButtonBuilder.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class UIButtonBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "button"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let button: UIButton = try initialize(layout, instance: instance, parent: parent)
        
        // Font
        let size = layout.getCGFloat("font-size", ifMissing: 17)
        let weight = try Convert.getFontWeight(layout, key: "font-weight")
        button.titleLabel?.font = UIFont.systemFontOfSize(size, weight: weight)
        
        if let title = layout.getString("title") {
            button.setTitle(title, forState: UIControlState.Normal)
        }

        if let bundle = layout.getString("image-bundle") {
            if let image = try Layout.imageLoader.loadImage(named: bundle) {
                button.setImage(image, forState: UIControlState.Normal)
            }
        }
        
        if let color = try layout.getUIColor("tint-color") {
            button.tintColor = color
        }
        
        if let color = try layout.getUIColor("title-color") {
            button.setTitleColor(color, forState: UIControlState.Normal)
        }
        
        if let touched = layout.getString("on-touch"), eventTarget = instance.eventTarget {
            button.addTarget(eventTarget, action: Selector(touched), forControlEvents: UIControlEvents.TouchUpInside)
            button.addTarget(eventTarget, action: Selector(touched), forControlEvents: UIControlEvents.TouchUpOutside)
        }
        
        if let insets = try Convert.getEdgeInsets(layout.getString("title-edge-insets")) {
            button.titleEdgeInsets = insets
        }
        
        if let insets = try Convert.getEdgeInsets(layout.getString("image-edge-insets")) {
            button.imageEdgeInsets = insets
        }
        
        if let align = layout.getString("text-alignment") {
            switch align.lowercaseString {
            case "left":
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            case "right":
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
            default:
                break;
            }
        }
        
        return button;
    }
}
