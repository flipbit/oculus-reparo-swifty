import Foundation
import UIKit

public class LayoutViewController : UIViewController {
    public var layout = Layout(filename: "")
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        layout.view = self.view
        layout.eventTarget = self
        
        viewWillLayout()
        
        do {
            try! layout.apply()
            viewDidLayout()
        } catch {
            print("Layout error")
        }
    }
        
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    public func viewWillLayout() {
    }
    
    public func viewDidLayout() {
    }
    
    public func viewWillRotate() throws {
        layout.debugger?.info("Screen rotation detected.")
        
        //relayoutViews()
    }
    
    override public func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        layout.debugger?.info("Trait collection changed.")
       
        if layout.laidOut {
            relayoutViews()
        }
    }
    
    func relayoutViews() {
        layout.clearDirective("landscape")
        layout.clearDirective("portrait")
        layout.directives.append(Hardware.orientation)

        if layout.needsLayout {
            try! layout.apply()
        } else {
            layout.debugger?.info("No changes required.")
        }
    }
}
