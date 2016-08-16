import Foundation
import UIKit

public class LayoutViewController : UIViewController {
    public var layout = Layout(filename: "")
    
    public override func viewDidLoad() {
        layout.view = self.view
        layout.eventTarget = self
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()        
        
        if layout.needsLayout {
            viewWillLayout()
            do {
                try layout.apply()
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
        
        Layout.debugger?.info("Trait collection changed.")
       
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
