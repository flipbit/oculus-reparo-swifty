//
//  LabelBuilder.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

extension OculusReparo {
    public class LabelBuilder : Builder, BuilderProtocol {
        public func canBuild(layout: Reparo.Section) -> Bool {
            return layout.key == "label"
        }
        
        public func build(layout: Reparo.Section, state: ViewState, parent: UIView) throws -> UIView {
            let label: UILabel = try initialize(layout, state: state, parent: parent)
            
            label.text = layout.getValue("text")
            label.textColor = try layout.getUIColor("text-color")
            
            if let align = layout.getValue("text-alignment") {
                switch align.lowercaseString {
                case "left":
                    label.textAlignment = NSTextAlignment.Left
                case "center":
                    label.textAlignment = NSTextAlignment.Center
                case "right":
                    label.textAlignment = NSTextAlignment.Right
                case "justified":
                    label.textAlignment = NSTextAlignment.Justified
                case "natural":
                    label.textAlignment = NSTextAlignment.Natural
                default:
                    break;
                }
            }
            
            return label;
        }
    }
}