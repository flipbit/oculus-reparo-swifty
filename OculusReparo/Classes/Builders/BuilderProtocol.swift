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
    func canBuild(layout: Section) -> Bool
    
    func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView
}