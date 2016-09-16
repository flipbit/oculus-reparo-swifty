import Foundation
import OculusReparo

public class SampleReader : ReparoReader {
    public func readFile(filename: String) throws -> String? {
        let path = getPath(filename + ".txt")
        return try read(path)
    }
    
    public func readIncludeFile(filename: String) throws -> String? {
        let path = getPath(filename)
        return try read(path)
    }
    
    private func getPath(filename: String) -> String {
        let bundlePath = NSBundle.mainBundle().resourcePath! //NSBundle(for: self)!.resourcePath!
        //let bundlePath = NSBundle(forClass: type(of: self)).resourcePath!
        let url = NSURL(fileURLWithPath: bundlePath)
        return url.URLByAppendingPathComponent(filename)!.path!
    }
    
    private func read(filename: String) throws -> String? {
        return try NSString(contentsOfFile: filename, encoding: NSUTF8StringEncoding) as String
    }
}
