import UIKit


open class UILayoutView : UIView {
    lazy open var layout: Layout = {
        let layout = Layout()
        layout.view = self
        layout.eventTarget = self
        layout.model =  self
        
        return layout
    }()
    
    override open func layoutSubviews() {
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
    
    open func viewWillLayout() {
    }
    
    open func viewDidLayout() {
    }
}
