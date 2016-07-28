import UIKit
import OculusReparo

class Item: NSObject {
    var text: String
    var layout: String
    
    init(text: String, layout: String) {
        self.text = text
        self.layout = layout
    }
}

class MenuController: UIViewController, UITableViewDelegate {
    let items = [
        Item(text: "Hello World", layout: "PositionPadding.layout"),
        Item(text: "Hello World", layout: "PositionPadding.layout"),
        Item(text: "Hello World", layout: "PositionPadding.layout"),
        Item(text: "Hello World", layout: "PositionPadding.layout")
    ]
    
    var layout: Layout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = Layout(filename: "Basic.layout", controller: self)
        
        layout!.variables["items"] = items
        
        try! layout!.apply()
        
        title = "Oculus Reparo Examples"

        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = items[indexPath.row]
        
        if let controller = storyboard?.instantiateViewControllerWithIdentifier("Example") as? ExampleController {
            controller.viewname = item.layout
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

