//
//  BundleConfigurationReader.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

open class BundleReader : ReparoReader {
    open func readFile(_ filename: String) throws -> String? {
        let path = getPath(filename)
        return try read(path)
    }
    
    open func readIncludeFile(_ filename: String) throws -> String? {
        let path = getPath(filename)
        return try read(path)
    }
    
    fileprivate func getPath(_ filename: String) -> String {
        let bundlePath = Bundle.main.resourcePath! //NSBundle(forClass: self.dynamicType).resourcePath!
        //let bundlePath = NSBundle(forClass: self.dynamicType).resourcePath!
        let url = URL(fileURLWithPath: bundlePath)
        return url.appendingPathComponent(filename).path
    }
    
    fileprivate func read(_ filename: String) throws -> String? {
        return try NSString(contentsOfFile: filename, encoding: String.Encoding.utf8.rawValue) as String
    }
}
