import Foundation

open class UITextFieldBuilder : ViewBuilder {
    override open func canBuild(_ layout: Section) -> Bool {
        return layout.key == "text-field"
    }
    
    override open func build(_ layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let field: UITextField = try initialize(layout, instance: instance, parent: parent)
        let size = layout.getCGFloat("font-size", ifMissing: 17)
        let weight = try Convert.getFontWeight(layout, key: "font-weight")
        
        field.text = layout.getString("text", ifMissing: "")
        field.textColor = try layout.getUIColor("text-color")
        field.font = UIFont.systemFont(ofSize: size, weight: weight)
        field.textAlignment = try Convert.getTextAlignment(layout.getString("text-alignment"), or: NSTextAlignment.left)
        field.placeholder = layout.getString("placeholder", ifMissing: "")
        field.isSecureTextEntry = try layout.getBool("secure-text-entry", or: false)
        
        if let color = try layout.getUIColor("placeholder-color", ifMissing: nil), let placeholder = field.placeholder {
            field.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName : color])
        }
        
        if let line = layout.getLine("return-key") {
            field.returnKeyType = try Convert.getReturnKeyType(line)
        }
        
        if let autocorrect = try layout.getBool("auto-correction") {
            if autocorrect {
                field.autocorrectionType = .yes
            } else {
                field.autocorrectionType = .no
            }
        } else {
            field.autocorrectionType = .default
        }

        if let line = layout.getLine("auto-capitalization") {
            field.autocapitalizationType = try Convert.getUITextAutocapitalizationType(line)
        }

        if let line = layout.getLine("keyboard-type") {
            field.keyboardType = try Convert.getUIKeyboardType(line)
        }

        /*
        if let line = layout.getLine("spell-checking-type", "spell-checking", "spelling") {
            field.spellCheckingType = try Convert.getUITextSpellCheckingType(line)
        }
        */
        
        return field;
    }
}
