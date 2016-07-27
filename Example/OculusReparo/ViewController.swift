import UIKit
import OculusReparo

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = Layout(filename: "Basic.layout", controller: self)
        
        try! layout.apply()
    }
}

