import Foundation

extension OculusReparo {
    public class SliderBuilder : Builder, BuilderProtocol {
        public func canBuild(layout: Reparo.Section) -> Bool {
            return layout.key == "slider"
        }
        
        public func build(layout: Reparo.Section, state: ViewState, parent: UIView) throws -> UIView {
            let slider: UISlider = try initialize(layout, state: state, parent: parent)
            
            slider.minimumValue = layout.getFloat("minimum-value", ifMissing: 0)
            slider.maximumValue = layout.getFloat("maximum-value", ifMissing: 100)
            slider.value = layout.getFloat("value", ifMissing: 0)
            
            if let color = try layout.getUIColor("tint-color") {
                    slider.tintColor = color
            }
            
            if let changed = layout.getValue("changed") where state.eventTarget != nil  {
                slider.addTarget(state.eventTarget!, action: Selector(changed), forControlEvents: UIControlEvents.TouchUpInside)
                slider.addTarget(state.eventTarget!, action: Selector(changed), forControlEvents: UIControlEvents.TouchUpOutside)
            }
            
            return slider;
        }
    }
}