//
//  ButtonBuilder.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

open class UIImageViewBuilder : ViewBuilder {
    override open func canBuild(_ layout: Section) -> Bool {
        return layout.key == "image"
    }
    
    override open func build(_ layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let imageView: UIImageView = try initialize(layout, instance: instance, parent: parent)
        
        let color = try layout.getUIColor("tint-color")
        
        if let bundle = layout.getString("image-bundle") {
            if var image = try Layout.imageLoader.loadImage(named: bundle) {
                if color != nil {
                    imageView.tintColor = color
                    
                    image = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                }
                
                imageView.image = image
            }
        }

        if let filename = layout.getString("image-file") {
            let frameworkBundle = Bundle.main
            if let imagePath = frameworkBundle.path(forResource: filename, ofType: "") {
                if var image = UIImage(contentsOfFile: imagePath) {
                    if color != nil {
                        imageView.tintColor = color
                    
                        image = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    }
                
                    imageView.image = image
                }
            }
            
        }

        if let line = layout.getLine("content-mode") {
            let contentMode = try Convert.getUIViewContentMode(line)
            
            imageView.contentMode = contentMode
        }
        
        return imageView;
    }
}
