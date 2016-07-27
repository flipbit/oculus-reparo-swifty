//
//  ButtonBuilder.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class UIImageViewBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "image"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let imageView: UIImageView = try initialize(layout, instance: instance, parent: parent)
        
        let color = try layout.getUIColor("tint-color")
        
        if let bundle = layout.getValue("image-bundle") {
            if var image = UIImage(named: bundle) {
                if color != nil {
                    imageView.tintColor = color
                    
                    image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                }
                
                imageView.image = image
            }
        }
        
        return imageView;
    }
}
