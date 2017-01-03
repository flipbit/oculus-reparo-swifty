import Foundation
import OculusReparo

open class SampleReader : ReparoReader {
    open func readFile(_ filename: String) throws -> String? {
        let path = getPath(filename + ".txt")
        return try read(path)
    }
    
    open func readIncludeFile(_ filename: String) throws -> String? {
        let path = getPath(filename)
        return try read(path)
    }
    
    fileprivate func getPath(_ filename: String) -> String {
        let bundlePath = Bundle.main.resourcePath! //NSBundle(for: self)!.resourcePath!
        //let bundlePath = NSBundle(forClass: type(of: self)).resourcePath!
        let url = URL(fileURLWithPath: bundlePath)
        return url.appendingPathComponent(filename).path
    }
    
    fileprivate func read(_ filename: String) throws -> String? {
        return try NSString(contentsOfFile: filename, encoding: String.Encoding.utf8.rawValue) as String
    }
}
