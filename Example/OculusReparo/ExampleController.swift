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
    }
}