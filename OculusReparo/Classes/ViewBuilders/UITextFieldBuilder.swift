import Foundation

public class UITextFieldBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "text-field"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let label: UITextField = try initialize(layout, instance: instance, parent: parent)
        let size = layout.getCGFloat("font-size", ifMissing: 17)
        let weight = try Convert.getFontWeight(layout, key: "font-weight")
        
        label.text = layout.getValue("text") ?? ""
        label.textColor = try layout.getUIColor("text-color")
        label.font = UIFont.systemFontOfSize(size, weight: weight)
        label.textAlignment = try Convert.getTextAlignment(layout.getValue("text-alignment"), or: NSTextAlignment.Left)
        label.placeholder = layout.getValue("placeholder") ?? ""
        
        return label;
    }
}
