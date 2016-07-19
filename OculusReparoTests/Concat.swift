import XCTest
@testable import OculusReparo

class concat: XCTestCase {
    
    func testConcat() {
        // Change this to your checkout location
        let path = "/Users/chris/Source/oculus-reparo-swifty/OculusReparo/"
        
        var files: [String] = []
        files.append("Builders/BuilderProtocol.swift")
        files.append("Layout.swift")
        files.append("Position.swift")
        files.append("Hardware.swift")
        files.append("Animation.swift")
        files.append("Convert.swift")
        files.append("LayoutError.swift")
        files.append("Builders/Builder.swift")
        files.append("Builders/UIViewBuilder.swift")
        files.append("Builders/UILabelBuilder.swift")
        files.append("Builders/UISliderBuilder.swift")
        files.append("Builders/UIButtonBuilder.swift")
        files.append("Builders/UIImageViewBuilder.swift")
        files.append("Builders/UITableViewBuilder.swift")
        files.append("Builders/UIScrollViewBuilder.swift")
        files.append("Extensions.swift")
        files.append("../Reparo/Reparo/Concat/Reparo.swift")
        
        let output = NSURL(fileURLWithPath: path + "Concat/OculusReparo.swift")
        
        try! createHeader(output)

        for file in files {
            let filename = path + file
            let data = NSData(contentsOfFile: filename)
            let string = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            let cleaned = clean(string)

            try! appendLineToURL(cleaned, fileURL: output)
        }
        
        
        XCTAssertTrue(true)
    }
    private func createHeader(url: NSURL) throws {
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        let fileManager = NSFileManager.defaultManager()
        try fileManager.removeItemAtURL(url)
        
        try appendLineToURL("//", fileURL: url)
        try appendLineToURL("// OculusReparo View Layouts", fileURL: url)
        try appendLineToURL("//", fileURL: url)
        try appendLineToURL("// For usage see:", fileURL: url)
        try appendLineToURL("//", fileURL: url)
        try appendLineToURL("// https://github.com/flipbit/oculus-reparo-swifty", fileURL: url)
        try appendLineToURL("//", fileURL: url)
        try appendLineToURL("// This file was auto generated on: \(timestamp)", fileURL: url)
        try appendLineToURL("//", fileURL: url)
        try appendLineToURL("import Foundation", fileURL: url)
        try appendLineToURL("import UIKit", fileURL: url)
    }
    
    private func clean(input: String) -> String {
        var cleaned = input.stringByReplacingOccurrencesOfString("import Foundation\n", withString: "")
        cleaned = cleaned.stringByReplacingOccurrencesOfString("import UIKit\n", withString: "")
        
        
        let lines = cleaned.componentsSeparatedByString("\n")
        var output: [String] = []
        var strippedHeader = false
        
        for line in lines {
            if line.hasPrefix("//") && !strippedHeader {
                continue
            } else {
                strippedHeader = true
                output.append(line)
                output.append("\n")
            }
        }
        
        return output.joinWithSeparator("")
    }
    
    private func appendLineToURL(value: String, fileURL: NSURL) throws {
        try appendToURL(value.stringByAppendingString("\n"), fileURL: fileURL)
    }
    
    private func appendToURL(value: String, fileURL: NSURL) throws {
        let data = value.dataUsingEncoding(NSUTF8StringEncoding)!
        if let fileHandle = try? NSFileHandle(forWritingToURL: fileURL) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.writeData(data)
        }
        else {
            try data.writeToURL(fileURL, options: .DataWritingAtomic)
        }
    }
}