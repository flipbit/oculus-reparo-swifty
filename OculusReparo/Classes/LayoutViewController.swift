import Foundation
import UIKit

public class LayoutViewController : UIViewController {
    public let layout = Layout()
    
    public func getViewName() -> String {
        let type = String(self.dynamicType)
        
        return type.stringByReplacingOccurrencesOfString("Controller", withString: "") + ".layout"
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()        
        
        if layout.needsLayout {
            if layout.view == nil {
                layout.view = view
                layout.eventTarget = self
            }
            
            if layout.filename == nil {
                layout.filename = getViewName()
            }
            
            viewWillLayout()
            do {
                try! layout.apply()
                viewDidLayout()
            } catch {
                print("Layout error")
            }
        }
    }

    public func viewWillLayout() {
    }
    
    public func viewDidLayout() {
    }
        
    override public func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        Layout.debugger?.debug("Trait collection changed.")
       
        if layout.laidOut {
            relayoutViews()
        }
    }
    
    func relayoutViews() {
        layout.clearDirective("landscape")
        layout.clearDirective("portrait")
        layout.directives.append(Hardware.orientation)

        if layout.needsLayout {
            do {
                try layout.apply()
                viewDidLayout()
            } catch {
                print("Layout error")
            }
        } else {
            Layout.debugger?.info("No changes required.")
        }
    }
}
