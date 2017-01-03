import Foundation
import UIKit

open class LayoutViewController : UIViewController {
    open let layout = Layout()
    
    open func getViewName() -> String {
        let type = String(describing: type(of: self))
        
        return type.replacingOccurrences(of: "Controller", with: "") + ".layout"
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()        
        
        if layout.needsLayout {
            if layout.view == nil {
                layout.view = view
                layout.eventTarget = self
            }
            
            if layout.filename == nil {
                layout.filename = getViewName()
            }
            
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
        
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
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
