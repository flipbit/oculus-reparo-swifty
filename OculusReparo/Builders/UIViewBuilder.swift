//
//  ViewBuilder.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class UIViewBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "view"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let view: UIView = try initialize(layout, instance: instance, parent: parent)
        
        return view;
    }
}
