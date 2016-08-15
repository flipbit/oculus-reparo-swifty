import Foundation
import UIKit
import OculusReparo

class ExampleController : LayoutViewController {
    var viewname: String?
    
    override func viewWillLayout() {
        layout.filename  = viewname
        layout.debugger = LayoutDebugger()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func onBack() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationController?.popViewControllerAnimated(true)
    }
}