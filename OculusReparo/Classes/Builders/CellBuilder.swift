import Foundation
import UIKit

public protocol CellBuilderProtocol {
    func canBuild(layout: Section) -> Bool
    
    func build(layout: Section, instance: Layout, table: UITableView, rowHeight: CGFloat) throws -> UITableViewCell
}

public class UITableViewCellBuilder : CellBuilderProtocol {
    public func initialize<T: UITableViewCell>(layout: Section, instance: Layout, table: UITableView, rowHeight: CGFloat) throws -> T {
        var view = T()
        
        //view.frame = CGRect(x: 0, y: 0, width: table.frame.width, height: rowHeight)
        /*
        view.backgroundColor = try layout.getUIColor("background-color")
        view.layer.zPosition = layout.getCGFloat("z-position", ifMissing: 0)
        view.layer.cornerRadius = layout.getCGFloat("corner-radius", ifMissing: 0)
        view.layer.borderColor = try layout.getCGColor("border-color")
        view.layer.borderWidth = layout.getCGFloat("border-width", ifMissing: 0)
        view.layer.opacity = layout.getFloat("opacity", ifMissing: 1)
        view.clipsToBounds = try layout.getBool("clips-to-bounds")
        view.hidden = try layout.getBool("hidden")
        view.userInteractionEnabled = try layout.getBool("user-interaction-enabled", ifMissing: true)
        view.accessibilityIdentifier = layout.getValue("accessibility-identifier")
        */
        return view
    }
    
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "cell"
    }
    
    public func build(layout: Section, instance: Layout, table: UITableView, rowHeight: CGFloat) throws -> UITableViewCell {
        let cell: UITableViewCell = try initialize(layout, instance: instance, table: table, rowHeight: rowHeight)
        
        if let text = layout.getValue("text") {
            cell.textLabel?.text = text
        }
        
        if let accessory = layout.getValue("accessory") {
            switch accessory.lowercaseString {
            case "none": cell.accessoryType = UITableViewCellAccessoryType.None
            case "checkmark": cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            case "detail-button": cell.accessoryType = UITableViewCellAccessoryType.DetailButton
            case "detail-disclosure-button": cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
            case "disclosure-indicator": cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            default: throw LayoutError.InvalidConfiguration("Unknown cell accessory type: \(accessory)")
            }
        }
        
        return cell;
    }
}

public class CellSource : NSObject, UITableViewDataSource {
    public var cells = [UITableViewCell]()
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
}