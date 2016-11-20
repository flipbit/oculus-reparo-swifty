import Foundation
import OculusReparo
import UIKit

/// UITableViewCell that renders it's contents using OculusReparo
public class UILayoutCell : UITableViewCell {
    /**
     The cell's Layout instance
     */
    public var layout: Layout

    /**
     Creates a new UILayoutCell instance
     
     - Parameter reuseIdentifier:   The cell reuse identifier
     */
    public init(reuseIdentifier: String) {
        layout = Layout()
        
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
        
        layout.view = self
        layout.filename = getViewName()
    }
    
    /**
     Creates a new UILayoutCell instance
     
     - Parameter layoutName:        The file name of the layout
     - Parameter reuseIdentifier:   The cell reuse identifier
     */
    public init(layoutName: String, reuseIdentifier: String) {
        layout = Layout(filename: layoutName)
        
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
        
        layout.view = self
    }
    
    /**
     Creates a new UILayoutCell instance
     */
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Occurs once before the initial layout
     */
    public func viewInitialLayout() {
    }
    
    /**
     Occurs before the cell's view is laid out
     */
    public func viewWillLayout() {
    }
    
    /**
     Occurs after the cell's view is laid out
     */
    public func viewDidLayout() {
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
     Laysout the cell's subviews
     */
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if layout.needsLayout {
            if layout.laidOut == false {
                viewInitialLayout()
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
            
            viewDidLayout()
        }
    }
}
