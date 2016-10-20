import Foundation
import UIKit

public class UILabelBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "label"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let label: UILabel = try initialize(layout, instance: instance, parent: parent)
        let size = layout.getCGFloat("font-size", ifMissing: 17)
        let weight = try Convert.getFontWeight(layout, key: "font-weight")
        
        label.numberOfLines = Int(layout.getValue("lines", ifMissing: "0")!)!
        label.text = layout.getValue("text")
        label.textColor = try layout.getUIColor("text-color")
        label.font = UIFont.systemFontOfSize(size, weight: weight)
        label.textAlignment = try Convert.getTextAlignment(layout.getValue("text-alignment"))
        
        return label;
    }
}
