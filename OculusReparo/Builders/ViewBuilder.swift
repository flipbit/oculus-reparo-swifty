//
//  ViewBuilder.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

extension OculusReparo {
    public class ViewBuilder : Builder, BuilderProtocol {
        public func canBuild(layout: Reparo.Section) -> Bool {
            return layout.key == "view"
        }
        
        public func build(layout: Reparo.Section, state: ViewState, parent: UIView) throws -> UIView {
            let view: UIView = try initialize(layout, state: state, parent: parent)
            
            return view;
        }
    }
}