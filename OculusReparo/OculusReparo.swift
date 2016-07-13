//
//  OculusReparo.swift
//  OculusReparo
//
//  Created by Chris on 06/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation
import UIKit

public struct OculusReparo {
    var builders: [BuilderProtocol]
    
    init() {
        builders = []
        
        builders.append(ViewBuilder())
        builders.append(LabelBuilder())
        builders.append(SliderBuilder())
        builders.append(ButtonBuilder())
        builders.append(ImageViewBuilder())
    }
    
    public func layout(filename: String, state: ViewState) throws -> ViewState {
        let parser = Reparo.Parser()
        parser.directives = state.directives
        
        let layout = try parser.parseFile(filename)
        
        try setProperties(layout, view: state.view)
        
        for section in layout.sections {
            try build(section, state: state, parent: state.view)
        }
        
        return state
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
    
    private func setProperties(layout: Reparo.Section, view: UIView) throws {
        if let properties = layout.getSection("layout") {
            view.backgroundColor = try properties.getUIColor("background-color")
        }
    }
    
    private func build(layout: Reparo.Section, state: ViewState, parent: UIView) throws {
        for builder in builders {
            if (builder.canBuild(layout)) {
                let view = try builder.build(layout, state: state, parent: parent)
                
                for section in layout.sections {
                    try build(section, state: state, parent: view)
                }
                    
                break
            }
        }
    }
}
