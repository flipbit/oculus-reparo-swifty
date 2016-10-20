import UIKit


public class UILayoutView : UIView {
    lazy public var layout: Layout = {
        let layout = Layout()
        layout.view = self
        layout.eventTarget = self
        layout.model = self
        
        return layout
    }()
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if layout.needsLayout {
            do {
                viewWillLayout()
                try layout.apply()
                viewDidLayout()
            } catch {
                print("Layout View Error!")
            }
        }
    }
    
    public func viewWillLayout() {
    }
    
    public func viewDidLayout() {
    }
}
