//
//  BuilderProtocol.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation
import UIKit

public protocol BuilderProtocol {
    func canBuild(layout: Reparo.Section) -> Bool
    
    func build(layout: Reparo.Section, state: OculusReparo.ViewState, parent: UIView) throws -> UIView
}