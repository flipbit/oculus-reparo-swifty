import Foundation

public class UISliderBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "slider"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let slider: UISlider = try initialize(layout, instance: instance, parent: parent)
        
        slider.minimumValue = layout.getFloat("minimum-value", ifMissing: 0)
        slider.maximumValue = layout.getFloat("maximum-value", ifMissing: 100)
        slider.value = layout.getFloat("value", ifMissing: 0)
        slider.continuous = try layout.getBool("continuous", ifMissing: false)
        
        if let color = try layout.getUIColor("tint-color") {
                slider.tintColor = color
        }
        
        if let changed = layout.getValue("changed"), eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), forControlEvents: UIControlEvents.ValueChanged)
        }
        
        if let changed = layout.getValue("touch-up-inside"), eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        if let changed = layout.getValue("touch-up-outside"), eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), forControlEvents: UIControlEvents.TouchUpOutside)
        }
        
        return slider;
    }
}
