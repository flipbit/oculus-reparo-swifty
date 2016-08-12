import Foundation
import UIKit
import OculusReparo

class ExampleController : UIViewController {
    var viewname: String?
    var layout: Layout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = Layout(filename: viewname!, controller: self)
        
        try! layout!.apply()
        
        layout?.enableAutoRotation = true
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        
        
        if let window = UIApplication.sharedApplication().keyWindow {
            print ("trait change key window \(window.frame.width)x\(window.frame.height)")
            layout?.screenSize = window.frame
            try! layout?.apply()
        }
        
    }
}