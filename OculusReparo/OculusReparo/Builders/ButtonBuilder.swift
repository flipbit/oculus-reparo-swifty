//
//  ButtonBuilder.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

extension OculusReparo {
    public class ButtonBuilder : Builder, BuilderProtocol {
        public func canBuild(layout: Reparo.Section) -> Bool {
            return layout.key == "button"
        }
        
        public func build(layout: Reparo.Section, state: ViewState, parent: UIView) throws -> UIView {
            let button: UIButton = try initialize(layout, state: state, parent: parent)
            
            if let title = layout.getValue("title") {
                button.setTitle(title, forState: UIControlState.Normal)
            }
            
            button.tintColor = try layout.getUIColor("tint-color")
            
            if state.eventTarget != nil {
                if let touched = layout.getValue("touched") {
                    button.addTarget(state.eventTarget!, action: Selector(touched), forControlEvents: UIControlEvents.TouchUpInside)
                    button.addTarget(state.eventTarget!, action: Selector(touched), forControlEvents: UIControlEvents.TouchUpOutside)
                }
            }
            
            return button;
        }
    }
}