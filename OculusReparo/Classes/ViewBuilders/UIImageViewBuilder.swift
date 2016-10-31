//
//  ButtonBuilder.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class UIImageViewBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "image"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let imageView: UIImageView = try initialize(layout, instance: instance, parent: parent)
        
        let color = try layout.getUIColor("tint-color")
        
        if let bundle = layout.getString("image-bundle") {
            if var image = try Layout.imageLoader.loadImage(named: bundle) {
                if color != nil {
                    imageView.tintColor = color
                    
                    image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                }
                
                imageView.image = image
            }
        }

        if let filename = layout.getString("image-file") {
            let frameworkBundle = NSBundle.mainBundle()
            if let imagePath = frameworkBundle.pathForResource(filename, ofType: "") {
                if var image = UIImage(contentsOfFile: imagePath) {
                    if color != nil {
                        imageView.tintColor = color
                    
                        image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    }
                
                    imageView.image = image
                }
            }
            
        }

        
        imageView.contentMode = UIViewContentMode.Top
        
        return imageView;
    }
}
