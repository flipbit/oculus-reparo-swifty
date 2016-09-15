import Foundation

public class UITableViewBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "table"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let table: UITableView = try initialize(layout, instance: instance, parent: parent)
        
        table.bounces = try layout.getBool("bounces", ifMissing: true)
        table.isScrollEnabled = try layout.getBool("scroll-enabled", ifMissing: true)
                
        if try layout.getBool("set-delegate") {
            if let delegate = instance.eventTarget as? UITableViewDelegate {
                table.delegate = delegate
            } else {
                throw LayoutError.invalidConfiguration("Event target is not a UITableViewDelegate")
            }
        }
        
        if instance.laidOut {
            if let indexes = table.indexPathsForVisibleRows {
                for index in indexes {
                    if let cell = table.cellForRow(at: index) {
                        if cell.frame.width != table.frame.width {
                            cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: table.frame.width, height: cell.frame.height)
                            cell.setNeedsDisplay()
                        }
                    }
                }
            }
        }
        
        return table;
    }
}
