import Foundation

public class UITableViewBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "table"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let table: UITableView = try initialize(layout, instance: instance, parent: parent)
        
        table.bounces = try layout.getBool("bounces", or: true)
        table.scrollEnabled = try layout.getBool("scroll-enabled", or: true)
                
        if try layout.getBool("set-delegate", or: false) {
            if let delegate = instance.eventTarget as? UITableViewDelegate {
                table.delegate = delegate
            } else {
                throw LayoutError.InvalidConfiguration("Event target is not a UITableViewDelegate")
            }
        }
        
        if instance.laidOut {
            if let indexes = table.indexPathsForVisibleRows {
                for index in indexes {
                    if let cell = table.cellForRowAtIndexPath(index) {
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
