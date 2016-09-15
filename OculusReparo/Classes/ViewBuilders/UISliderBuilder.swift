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
        slider.isContinuous = try layout.getBool("continuous", ifMissing: false)
        
        if let color = try layout.getUIColor("tint-color") {
                slider.tintColor = color
        }
        
        if let changed = layout.getValue("changed"), let eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), forControlEvents: UIControlEvents.valueChanged)
        }
        
        if let changed = layout.getValue("touch-up-inside"), let eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), forControlEvents: UIControlEvents.touchUpInside)
        }
        
        if let changed = layout.getValue("touch-up-outside"), let eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), forControlEvents: UIControlEvents.touchUpOutside)
        }
        
        if let image = layout.getValue("thumb-image") {
            if let image = try Layout.imageLoader.loadImage(named: image) {
                slider.setThumbImage(image, forState: UIControlState())
            }
        }

        if let image = layout.getValue("maximum-track-image") {
            if let image = try Layout.imageLoader.loadImage(named: image) {
                slider.setMaximumTrackImage(image, forState: UIControlState())
            }
        }
        
        if let image = layout.getValue("minimum-track-image") {
            if let image = try Layout.imageLoader.loadImage(named: image) {
                slider.setMinimumTrackImage(image, forState: UIControlState())
            }
        }
        
        return slider;
    }
}
