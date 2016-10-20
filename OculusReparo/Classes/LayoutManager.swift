import Foundation
/*
public protocol UILayoutable : UIView {
}

extension UILayoutable where self: UIView {
    func applyLayout() {
        
    }
}
ublic protocol UILayoutable : UIView {
    /*
    let view: UIView
    let model: NSObject
    let eventTarget: NSObject
    */
    
    lazy public var layout: Layout = {
        let layout = Layout()
        layout.view = self.view
        layout.eventTarget = self.eventTarget
        layout.model = self.model
        
        return layout
    }()
    
    public init(view: UIView) {
        self.view = view
        self.model = view
        self.eventTarget = view
    }
    
    public func apply() {
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
 */
