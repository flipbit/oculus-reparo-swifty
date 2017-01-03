//
//  ButtonBuilder.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

open class UIButtonBuilder : ViewBuilder {
    override open func canBuild(_ layout: Section) -> Bool {
        return layout.key == "button"
    }
    
    override open func build(_ layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let button: UIButton = try initialize(layout, instance: instance, parent: parent)
        
        // Font
        let size = layout.getCGFloat("font-size", ifMissing: 17)
        let weight = try Convert.getFontWeight(layout, key: "font-weight")
        button.titleLabel?.font = UIFont.systemFont(ofSize: size, weight: weight)
        
        if let title = layout.getString("title") {
            button.setTitle(title, for: UIControlState())
        }

        if let bundle = layout.getString("image-bundle") {
            if let image = try Layout.imageLoader.loadImage(named: bundle) {
                button.setImage(image, for: UIControlState())
            }
        }
        
        if let color = try layout.getUIColor("tint-color") {
            button.tintColor = color
        }
        
        if let color = try layout.getUIColor("title-color") {
            button.setTitleColor(color, for: UIControlState())
        }
        
        if let touched = layout.getString("on-touch"), let eventTarget = instance.eventTarget {
            button.addTarget(eventTarget, action: Selector(touched), for: UIControlEvents.touchUpInside)
            button.addTarget(eventTarget, action: Selector(touched), for: UIControlEvents.touchUpOutside)
        }
        
        if let insets = try Convert.getEdgeInsets(layout.getString("title-edge-insets")) {
            button.titleEdgeInsets = insets
        }
        
        if let insets = try Convert.getEdgeInsets(layout.getString("image-edge-insets")) {
            button.imageEdgeInsets = insets
        }
        
        if let align = layout.getString("text-alignment") {
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
