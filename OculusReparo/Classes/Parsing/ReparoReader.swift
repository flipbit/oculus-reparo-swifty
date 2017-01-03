//
//  ReparoReader.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public protocol ReparoReader {
    func readFile(_ filename: String) throws -> String?
    
    func readIncludeFile(_ filename: String) throws -> String?
}
