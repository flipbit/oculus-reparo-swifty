import Foundation

public class UITextFieldBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "text-field"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let field: UITextField = try initialize(layout, instance: instance, parent: parent)
        let size = layout.getCGFloat("font-size", ifMissing: 17)
        let weight = try Convert.getFontWeight(layout, key: "font-weight")
        
        field.text = layout.getString("text", ifMissing: "")
        field.textColor = try layout.getUIColor("text-color")
        field.font = UIFont.systemFontOfSize(size, weight: weight)
        field.textAlignment = try Convert.getTextAlignment(layout.getString("text-alignment"), or: NSTextAlignment.Left)
        field.placeholder = layout.getString("placeholder", ifMissing: "")
        field.secureTextEntry = try layout.getBool("secure-text-entry", or: false)
        
        if let line = layout.getLine("return-key") {
            field.returnKeyType = try Convert.getReturnKeyType(line)
        }
        
        if let autocorrect = try layout.getBool("auto-correction") {
            if autocorrect {
                field.autocorrectionType = .Yes
            } else {
                field.autocorrectionType = .No
            }
        } else {
            field.autocorrectionType = .Default
        }

        if let line = layout.getLine("auto-capitalization") {
            field.autocapitalizationType = try Convert.getUITextAutocapitalizationType(line)
        }
        
        return field;
    }
}
