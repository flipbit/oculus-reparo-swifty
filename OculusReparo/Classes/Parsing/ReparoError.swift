//
//  ReparoError.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public enum ReparoError: ErrorType {
    case InvalidConfigurationLine(String)
    case InvalidColorString(String)
    case MissingConfigurationFile(String)
    case RecursiveIncludeDetected
    case MissingSectionEnd(String)
}
