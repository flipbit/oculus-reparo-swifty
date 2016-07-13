//
//  OculusReparoError.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

extension OculusReparo {
    enum OculusReparoError: ErrorType {
        case MissingViewPosition(String)
    }
}