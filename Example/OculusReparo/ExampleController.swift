import Foundation
import UIKit
import OculusReparo

class ExampleController : LayoutViewController {
    var viewname: String?
    
    override func viewWillLayout() {
        layout.filename  = viewname
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func onBack() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationController?.popViewController(animated: true)
    }
}
