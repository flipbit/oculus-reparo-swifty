import Foundation
import UIKit
import OculusReparo

class TrafficLightsController : LayoutViewController {
    var red: CALayer?                               // Mapped automatically from our view
    var amber: CALayer?
    var green: CALayer?
    
    override func viewWillLayout() {
        layout.filename  = "TrafficLights.layout"   // The name of our text file
        layout.model = self                         // Sets object to map to
    }
    
    override func viewDidLayout() {
        // Start a timer
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
    }
    
    // Invoked from the view
    func onBack() {
        navigationController?.popViewController(animated: true)        
    }
    
    // Animate our lights
    func onTimer(_ timer: Timer) {
        if red?.opacity == 1 {
            red?.opacity = 0.5
            amber?.opacity = 1
        }

        else if amber?.opacity == 1 {
            amber?.opacity = 0.5
            green?.opacity = 1
        }

        else {
            green?.opacity = 0.5
            red?.opacity = 1
        }
    }
}
