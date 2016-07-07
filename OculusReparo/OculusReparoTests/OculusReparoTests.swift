//
//  OculusReparoTests.swift
//  OculusReparoTests
//
//  Created by Chris on 06/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import XCTest
@testable import OculusReparo

class OculusReparoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseLine() {
        let machine = OculusReparo.StateMachine(input: "hello;")
        
        let line = machine.read()!
        
        XCTAssertTrue(line.key == "hello")
        XCTAssertTrue(line.number == 1)
        
        XCTAssertNil(machine.read())
    }
    
    func testParseMultipleLines() {
        let machine = OculusReparo.StateMachine(input: "hello;world;")
        
        let hello = machine.read()!
        
        XCTAssertTrue(hello.key == "hello")
        XCTAssertTrue(hello.number == 1)

        let world = machine.read()!
        
        XCTAssertTrue(world.key == "world")
        XCTAssertTrue(world.number == 1)
        
        XCTAssertNil(machine.read())
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
