//
//  OculusReparoError.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

enum LayoutError: ErrorType {
    case MissingViewPosition(String)
    case MissingRootView
    case MissingModelProperty(String)
    case UnknownFontWeight(String)
    case InvalidInsetFormat(String)
    case InvalidTextAlignment(String)
}
