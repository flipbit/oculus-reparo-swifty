import Foundation

open class UISliderBuilder : ViewBuilder {
    override open func canBuild(_ layout: Section) -> Bool {
        return layout.key == "slider"
    }
    
    override open func build(_ layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let slider: UISlider = try initialize(layout, instance: instance, parent: parent)
        
        slider.minimumValue = layout.getFloat("minimum-value", ifMissing: 0)
        slider.maximumValue = layout.getFloat("maximum-value", ifMissing: 100)
        slider.value = layout.getFloat("value", ifMissing: 0)
        slider.isContinuous = try layout.getBool("continuous", or: false)
        
        if let color = try layout.getUIColor("tint-color") {
                slider.tintColor = color
        }
        
        if let changed = layout.getString("changed"), let eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), for: UIControlEvents.valueChanged)
        }
        
        if let changed = layout.getString("touch-up-inside"), let eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), for: UIControlEvents.touchUpInside)
        }
        
        if let changed = layout.getString("touch-up-outside"), let eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), for: UIControlEvents.touchUpOutside)
        }
        
        if let image = layout.getString("thumb-image") {
            if let image = try Layout.imageLoader.loadImage(named: image) {
                slider.setThumbImage(image, for: UIControlState())
            }
        }

        if let image = layout.getString("maximum-track-image") {
            if let image = try Layout.imageLoader.loadImage(named: image) {
                slider.setMaximumTrackImage(image, for: UIControlState())
            }
        }
        
        if let image = layout.getString("minimum-track-image") {
            if let image = try Layout.imageLoader.loadImage(named: image) {
                slider.setMinimumTrackImage(image, for: UIControlState())
            }
        }
        
        return slider;
    }
}
