//
//  ReparoError.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public enum ReparoError: Error {
    case invalidConfigurationLine(String)
    case invalidColorString(String)
    case missingConfigurationFile(String)
    case recursiveIncludeDetected
    case missingSectionEnd(String)
}
