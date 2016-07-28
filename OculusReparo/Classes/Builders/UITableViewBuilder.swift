import Foundation

public class UITableViewBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "table"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let table: UITableView = try initialize(layout, instance: instance, parent: parent)
        
        table.bounces = try layout.getBool("bounces", ifMissing: true)
        table.scrollEnabled = try layout.getBool("scroll-enabled", ifMissing: true)
        
        if let cells = layout.getSection("cells") {
            let height = layout.getCGFloat("height", ifMissing: 44)
            
            var source = CellSource()
            
            for section in cells.sections {
                if let cell = try buildCell(section, instance: instance, table: table, rowHeight: height) {
                    source.cells.append(cell)
                }
            }
            
            table.rowHeight = height
            
            instance.dataSources.append(source)
            
            table.dataSource = source
            table.reloadData()
        }
        
        if try layout.getBool("set-delegate") {
            if let delegate = instance.eventTarget as? UITableViewDelegate {
                table.delegate = delegate
            } else {
                throw LayoutError.InvalidConfiguration("Event target is not a UITableViewDelegate")
            }
        }
        
        return table;
    }
    
    public func buildCell(layout: Section, instance: Layout, table: UITableView, rowHeight: CGFloat) throws -> UITableViewCell? {
        for builder in Layout.cellBuilders {
            if (builder.canBuild(layout)) {
                return try builder.build(layout, instance: instance, table: table, rowHeight: rowHeight)
            }
        }
        
        return nil
    }

}
