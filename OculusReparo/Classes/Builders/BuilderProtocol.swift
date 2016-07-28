import Foundation
import UIKit

public protocol BuilderProtocol {
    func canBuild(layout: Section) -> Bool
    
    func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView
}