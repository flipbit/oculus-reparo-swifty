import Foundation
import OculusReparo
import UIKit

/// UITableViewCell that renders it's contents using OculusReparo
open class UILayoutCell : UITableViewCell {
    /**
     The cell's Layout instance
     */
    open var layout: Layout

    /**
     Creates a new UILayoutCell instance
     
     - Parameter reuseIdentifier:   The cell reuse identifier
     */
    public init(reuseIdentifier: String) {
        layout = Layout()
        
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        
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
        
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        
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
    open func willInitLayout() {
    }

    /**
     Occurs once after the initial layout
     */
    open func didInitLayout() {
    }
    
    /**
     Occurs before the cell's view is laid out
     */
    open func viewWillLayout() {
    }
    
    /**
     Occurs after the cell's view is laid out
     */
    open func viewDidLayout() {
    }
    
    /**
     Returns the name of the layout file to use for the cell.
     This value is not used if the filename is specified in the cell
     constructor.
     If not overridden, this will be: [class name].layout
     */
    open func getViewName() -> String {
        return String(describing: type(of: self)) + ".layout"
    }
    
    /**
     Laysout the cell's subviews
     */
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if layout.needsLayout {
            if layout.laidOutCount == 0 {
                willInitLayout()
            }
            
            viewWillLayout()
            
            do {
                try layout.apply()
            } catch LayoutError.configurationError(let info) {
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
}
