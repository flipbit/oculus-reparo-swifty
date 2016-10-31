import UIKit


public class UILayoutView : UIView {
    lazy public var layout: Layout = {
        let layout = Layout()
        layout.view = self
        layout.eventTarget = self
        layout.model = self
        layout.filename = self.getViewName()
        
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
    
    /**
     Returns the name of the layout file to use for the cell.
     This value is not used if the filename is specified in the cell
     constructor.
     If not overridden, this will be: [class name].layout
     */
    public func getViewName() -> String {
        return String(self.dynamicType) + ".layout"
    }
    
    public func viewWillLayout() {
    }
    
    public func viewDidLayout() {
    }
}
