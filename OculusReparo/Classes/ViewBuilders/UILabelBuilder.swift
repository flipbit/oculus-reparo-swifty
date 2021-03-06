import Foundation
import UIKit

open class UILabelBuilder : ViewBuilder {
    override open func canBuild(_ layout: Section) -> Bool {
        return layout.key == "label"
    }
    
    override open func build(_ layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let label: UILabel = try initialize(layout, instance: instance, parent: parent)
        let size = layout.getCGFloat("font-size", ifMissing: 17)
        let weight = try Convert.getFontWeight(layout, key: "font-weight")
        
        label.numberOfLines = Int(layout.getString("lines", ifMissing: "0")!)!
        label.text = layout.getString("text")
        label.textColor = try layout.getUIColor("text-color")
        label.font = UIFont.systemFont(ofSize: size, weight: weight)
        label.textAlignment = try Convert.getTextAlignment(layout.getString("text-alignment"))
        label.adjustsFontSizeToFitWidth = try layout.getBool("adjusts-font-size-to-fit-width", or: false)
        
        if let factor = layout.getCGFloat("minimum-scale-factor") {
            label.minimumScaleFactor = factor
        }
        
        return label;
    }
}
