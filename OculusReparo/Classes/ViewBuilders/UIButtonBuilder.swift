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
        let weight = try Convert.getFontWeight(layout.getValue("font-weight"))
        button.titleLabel?.font = UIFont.systemFont(ofSize: size, weight: weight)
        
        if let title = layout.getValue("title") {
            button.setTitle(title, forState: UIControlState())
        }

        if let bundle = layout.getValue("image-bundle") {
            if let image = try Layout.imageLoader.loadImage(named: bundle) {
                button.setImage(image, forState: UIControlState())
            }
        }
        
        if let color = try layout.getUIColor("tint-color") {
            button.tintColor = color
        }
        
        if let color = try layout.getUIColor("title-color") {
            button.setTitleColor(color, forState: UIControlState())
        }
        
        if let touched = layout.getValue("on-touch"), let eventTarget = instance.eventTarget {
            button.addTarget(eventTarget, action: Selector(touched), forControlEvents: UIControlEvents.touchUpInside)
            button.addTarget(eventTarget, action: Selector(touched), forControlEvents: UIControlEvents.touchUpOutside)
        }
        
        if let insets = try Convert.getEdgeInsets(layout.getValue("title-edge-insets")) {
            button.titleEdgeInsets = insets
        }
        
        if let insets = try Convert.getEdgeInsets(layout.getValue("image-edge-insets")) {
            button.imageEdgeInsets = insets
        }
        
        if let align = layout.getValue("text-alignment") {
            switch align.lowercased() {
            case "left":
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            case "right":
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
            default:
                break;
            }
        }
        
        return button;
    }
}
