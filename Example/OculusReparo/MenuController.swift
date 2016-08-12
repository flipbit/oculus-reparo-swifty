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

class MenuController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let items = [
        Item(text: "Hello World", layout: "PositionPadding.layout"),
        Item(text: "Hello World", layout: "PositionPadding.layout"),
        Item(text: "Hello World", layout: "PositionPadding.layout"),
        Item(text: "Hello World", layout: "PositionPadding.layout")
    ]
    
    var layout: Layout?
    var table: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = Layout(filename: "Basic.layout", controller: self)
        
        layout?.variables["items"] = items
        layout?.enableAutoRotation = true
        
        try! layout!.apply()
        
        title = "Oculus Reparo Examples"

        table = layout?.findView("table") as? UITableView
        table?.dataSource = self
        table?.delegate = self
        table?.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let reused = tableView.dequeueReusableCellWithIdentifier("menu-cell") {
            cell = reused
        } else {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "menu-cell")
        }
        
        
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.text
        cell.accessoryType = .DisclosureIndicator
        
        return cell
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

