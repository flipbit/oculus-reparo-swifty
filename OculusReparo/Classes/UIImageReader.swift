import UIKit

public protocol UIImageLoader {
    func loadImage(named name: String) throws -> UIImage?
}

public class MainBundleImageLoader : UIImageLoader {
    public func loadImage(named name: String) throws -> UIImage? {
        if name == "&empty" {
            return UIImage()
        }
        return UIImage(named: name)
    }
}
