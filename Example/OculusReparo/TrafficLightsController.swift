import Foundation
import UIKit
import OculusReparo

class TrafficLightsController : LayoutViewController {
    var red: CALayer?
    var amber: CALayer?
    var green: CALayer?
    
    override func viewWillLayout() {
        layout.filename  = "TrafficLights.layout"
        layout.model = self
    }
    
    override func viewDidLayout() {
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
    }
    
    func onBack() {
        navigationController?.popViewControllerAnimated(true)        
    }
    
    func onTimer(timer: NSTimer) {
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