//
//  BundleConfigurationReader.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class BundleReader : ReparoReader {
    public func readFile(filename: String) throws -> String? {
        let path = getPath(filename)
        return try read(path)
    }
    
    public func readIncludeFile(filename: String) throws -> String? {
        let path = getPath(filename)
        return try read(path)
    }
    
    private func getPath(filename: String) -> String {
        let bundlePath = NSBundle.mainBundle().resourcePath! //NSBundle(forClass: self.dynamicType).resourcePath!
        let url = NSURL(fileURLWithPath: bundlePath)
        return url.URLByAppendingPathComponent(filename)!.path!
    }
    
    private func read(filename: String) throws -> String? {
        return try NSString(contentsOfFile: filename, encoding: NSUTF8StringEncoding) as String
    }
}
