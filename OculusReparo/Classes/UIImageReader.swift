import UIKit

public protocol UIImageLoader {
    func loadImage(named name: String) throws -> UIImage?
}

open class MainBundleImageLoader : UIImageLoader {
    open func loadImage(named name: String) throws -> UIImage? {
        if name == "&empty" {
            return UIImage()
        }
        return UIImage(named: name)
    }
}
