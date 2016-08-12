import Foundation

public class UITableViewBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "table"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let table: UITableView = try initialize(layout, instance: instance, parent: parent)
        
        table.bounces = try layout.getBool("bounces", ifMissing: true)
        table.scrollEnabled = try layout.getBool("scroll-enabled", ifMissing: true)
                
        if try layout.getBool("set-delegate") {
            if let delegate = instance.eventTarget as? UITableViewDelegate {
                table.delegate = delegate
            } else {
                throw LayoutError.InvalidConfiguration("Event target is not a UITableViewDelegate")
            }
        }
        
        return table;
    }
}
