import Foundation

public class UITableViewBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "table"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let table: UITableView = try initialize(layout, instance: instance, parent: parent)
        
        table.bounces = try layout.getBool("bounces", ifMissing: true)
        table.scrollEnabled = try layout.getBool("scroll-enabled", ifMissing: true)
        
        return table;
    }
}
