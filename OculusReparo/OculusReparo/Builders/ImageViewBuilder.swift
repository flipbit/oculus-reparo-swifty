//
//  ButtonBuilder.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

extension OculusReparo {
    public class ImageViewBuilder : Builder, BuilderProtocol {
        public func canBuild(layout: Reparo.Section) -> Bool {
            return layout.key == "image-view"
        }
        
        public func build(layout: Reparo.Section, state: ViewState, parent: UIView) throws -> UIView {
            let button: UIImageView = try initialize(layout, state: state, parent: parent)
                        
            return button;
        }
    }
}