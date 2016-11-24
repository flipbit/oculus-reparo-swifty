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
            if layout.laidOutCount == 0 {
                willInitLayout()
            }
            
            viewWillLayout()
            
            do {
                try layout.apply()
            } catch LayoutError.ConfigurationError(let info) {
                Layout.debugger?.error(info)
                
                assertionFailure("Fatal Layout Error!")
            } catch {
                assertionFailure("Fatal Layout Error: \(error)")
            }

            if layout.laidOutCount == 1 {
                didInitLayout()
            }
            
            viewDidLayout()
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
    
    /**
     Occurs once before the initial layout
     */
    public func willInitLayout() {
    }
    
    /**
     Occurs once after the initial layout
     */
    public func didInitLayout() {
    }
    
    public func viewWillLayout() {
    }
    
    public func viewDidLayout() {
    }
}
