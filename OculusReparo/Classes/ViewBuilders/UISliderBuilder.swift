import Foundation

public class UISliderBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "slider"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let slider: UISlider = try initialize(layout, instance: instance, parent: parent)
        
        slider.minimumValue = layout.getFloat("minimum-value", ifMissing: 0)
        slider.maximumValue = layout.getFloat("maximum-value", ifMissing: 100)
        slider.value = layout.getFloat("value", ifMissing: 0)
        slider.continuous = try layout.getBool("continuous", or: false)
        
        if let color = try layout.getUIColor("tint-color") {
                slider.tintColor = color
        }
        
        if let changed = layout.getString("changed"), eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), forControlEvents: UIControlEvents.ValueChanged)
        }
        
        if let changed = layout.getString("touch-up-inside"), eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        if let changed = layout.getString("touch-up-outside"), eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), forControlEvents: UIControlEvents.TouchUpOutside)
        }
        
        if let image = layout.getString("thumb-image") {
            if let image = try Layout.imageLoader.loadImage(named: image) {
                slider.setThumbImage(image, forState: .Normal)
            }
        }

        if let image = layout.getString("maximum-track-image") {
            if let image = try Layout.imageLoader.loadImage(named: image) {
                slider.setMaximumTrackImage(image, forState: .Normal)
            }
        }
        
        if let image = layout.getString("minimum-track-image") {
            if let image = try Layout.imageLoader.loadImage(named: image) {
                slider.setMinimumTrackImage(image, forState: .Normal)
            }
        }
        
        return slider;
    }
}
