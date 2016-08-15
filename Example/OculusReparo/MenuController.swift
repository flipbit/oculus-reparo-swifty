import UIKit
import OculusReparo

class MenuController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var items = [MenuItem]()
    var type = MenuItem.MenuType.Main
    var layout: Layout?
    var table: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = MenuItem.GetMenuItems(type)
        
        layout = Layout(filename: "Menu.layout", controller: self)
        
        layout?.variables["items"] = items
        layout?.enableAutoRotation = true
        
        try! layout!.apply()
        
        title = type.rawValue

        table = layout?.findView("table") as? UITableView
        table?.dataSource = self
        table?.delegate = self
        table?.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: MenuItemCell
        if let reused = tableView.dequeueReusableCellWithIdentifier(MenuItemCell.cellReuseIdentifier) as? MenuItemCell {
            cell = reused
        } else {
            cell = MenuItemCell()
        }
        
        let item = items[indexPath.row]
        
        cell.load(item)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = items[indexPath.row]
        
        if let layout = item.layout {
            if let controller = storyboard?.instantiateViewControllerWithIdentifier("Example") as? ExampleController {
                controller.viewname = layout
                
                navigationController?.pushViewController(controller, animated: true)
            }
        } else if let menu = item.menu {
            if let controller = storyboard?.instantiateViewControllerWithIdentifier("Menu") as? MenuController {
                controller.type = menu
                
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

class MenuItemCell: UITableViewCell {
    static let cellReuseIdentifier = "menu-cell"
    
    init() {
        super.init(style: .Default, reuseIdentifier: MenuItemCell.cellReuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(item: MenuItem) {
        textLabel?.text = item.text
        accessoryType = .DisclosureIndicator
    }
}

class MenuItem: NSObject {
    var text: String
    var layout: String?
    var menu: MenuType?
    
    init(text: String, layout: String) {
        self.text = text
        self.layout = layout
    }

    init(text: String, menu: MenuType) {
        self.text = text
        self.menu = menu
    }

    enum MenuType : String {
        case Main = "Main"
        case Positioning = "Positioning"
    }
    
    static func GetMenuItems(menu: MenuType) -> [MenuItem] {
        switch menu {
        case MenuType.Main:
            return [
                MenuItem(text: "Positioning", menu: MenuType.Positioning),
                MenuItem(text: "Controls", layout: "PositionPadding.layout"),
                MenuItem(text: "Binding", layout: "PositionPadding.layout"),
                MenuItem(text: "Extensions", layout: "PositionPadding.layout")
            ]

        case MenuType.Positioning:
            return [
                MenuItem(text: "Basic", layout: "Basic.layout")
            ]
        }
    }
}
