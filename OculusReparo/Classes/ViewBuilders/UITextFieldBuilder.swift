import Foundation

public class UITextFieldBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "text-field"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let label: UITextField = try initialize(layout, instance: instance, parent: parent)
        let size = layout.getCGFloat("font-size", ifMissing: 17)
        let weight = try Convert.getFontWeight(layout, key: "font-weight")
        
        label.text = layout.getString("text", ifMissing: "")
        label.textColor = try layout.getUIColor("text-color")
        label.font = UIFont.systemFontOfSize(size, weight: weight)
        label.textAlignment = try Convert.getTextAlignment(layout.getString("text-alignment"), or: NSTextAlignment.Left)
        label.placeholder = layout.getString("placeholder", ifMissing: "")
        label.secureTextEntry = try layout.getBool("secure-text-entry", ifMissing: false)
        
        if let line = layout.getLine("return-key") {
            label.returnKeyType = try Convert.getReturnKeyType(line)
        }
        
        return label;
    }
}
