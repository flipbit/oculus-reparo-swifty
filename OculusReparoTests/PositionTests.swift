//
//  OculusReparoPositionTests.swift
//  OculusReparo
//
//  Created by Chris on 07/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import XCTest
import UIKit
@testable import OculusReparo

class PositionTests: XCTestCase {
    var view: UIView?
    
    override func setUp() {
        super.setUp()
        view = UIView()
        view?.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
    }
    
    func testParseFrameFillParentByDefault() {
        let position = Position(parent: view!)
        
        let frame = position.toFrame()
        
        XCTAssertTrue(frame.origin.x == 0)
        XCTAssertTrue(frame.origin.y == 0)
        XCTAssertTrue(frame.width == 200)
        XCTAssertTrue(frame.height == 100)
    }
    
    func testParseFrameWithAbsoluteValues() {
        let position = Position(parent: view!)
        
        position.top = "25"
        position.left = "35"
        position.height = "75"
        position.width = "99"
        
        let frame = position.toFrame()
        
        XCTAssertTrue(frame.origin.y == 25)
        XCTAssertTrue(frame.origin.x == 35)
        XCTAssertTrue(frame.height == 75)
        XCTAssertTrue(frame.width == 99)
    }
    
    func testParseFrameWithPercentageValues() {
        let position = Position(parent: view!)
        
        position.top = "10%"
        position.left = "20%"
        position.height = "75%"
        position.width = "50%"
        
        let frame = position.toFrame()
        
        XCTAssertTrue(frame.origin.y == 10)
        XCTAssertTrue(frame.origin.x == 40)
        XCTAssertTrue(frame.height == 75)
        XCTAssertTrue(frame.width == 100)
    }
    
    func testParseAlignments() {
        let position = Position(parent: view!)
        
        position.top = "50%"
        position.left = "50%"
        position.height = "50"
        position.width = "100"
        position.horizontalAlignment = Position.HorizontalAlignment.Center
        position.verticalAlignment = Position.VerticalAlignment.Middle
        
        let frame = position.toFrame()
        
        XCTAssertTrue(frame.origin.y == 25)
        XCTAssertTrue(frame.origin.x == 50)
        XCTAssertTrue(frame.height == 50)
        XCTAssertTrue(frame.width == 100)
    }

    func testParseRelativePositions() {
        let child = UIView()
        child.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        view!.addSubview(child)
        
        let position = Position(parent: view!)
        
        position.top = "+10"
        position.left = "+10"
        position.height = "50"
        position.width = "50"
        
        let frame = position.toFrame()
        
        XCTAssertTrue(frame.origin.y == 110)
        XCTAssertTrue(frame.origin.x == 110)
        XCTAssertTrue(frame.height == 50)
        XCTAssertTrue(frame.width == 50)
    }
}
