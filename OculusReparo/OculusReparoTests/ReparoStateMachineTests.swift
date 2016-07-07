//
//  OculusReparoTests.swift
//  OculusReparoTests
//
//  Created by Chris on 06/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import XCTest
@testable import OculusReparo

class ReparoStateMachineTests: XCTestCase {
    
    func testParseLine() {
        let machine = Reparo.StateMachine(input: "hello;", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "hello")
        XCTAssertTrue(line.lineNumber == 1)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseMultipleLines() {
        let machine = Reparo.StateMachine(input: "hello;world;", filename: "")
        
        let hello = try! machine.read()!
        
        XCTAssertTrue(hello.key == "hello")
        XCTAssertTrue(hello.lineNumber == 1)
        
        let world = try! machine.read()!
        
        XCTAssertTrue(world.key == "world")
        XCTAssertTrue(world.lineNumber == 1)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseMultipleLinesWithWindowsNewlines() {
        let machine = Reparo.StateMachine(input: "hello;\r\nworld;", filename: "")
        
        let hello = try! machine.read()!
        
        XCTAssertTrue(hello.key == "hello")
        XCTAssertTrue(hello.lineNumber == 1)
        
        let world = try! machine.read()!
        
        XCTAssertTrue(world.key == "world")
        XCTAssertTrue(world.lineNumber == 2)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithValue() {
        let machine = Reparo.StateMachine(input: "hello: world;", filename: "")
        
        let hello = try! machine.read()!
        
        XCTAssertTrue(hello.key == "hello")
        XCTAssertTrue(hello.value == "world")
        XCTAssertTrue(hello.lineNumber == 1)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseMultipleLinesWithValue() {
        let machine = Reparo.StateMachine(input: "hello: world;\nsecond: line;", filename: "")
        
        let first = try! machine.read()!
        
        XCTAssertTrue(first.key == "hello")
        XCTAssertTrue(first.value == "world")
        XCTAssertTrue(first.lineNumber == 1)

        let second = try! machine.read()!
        
        XCTAssertTrue(second.key == "second")
        XCTAssertTrue(second.value == "line")
        XCTAssertTrue(second.lineNumber == 2)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseSection() {
        let machine = Reparo.StateMachine(input: "hello {}", filename: "")
        
        let first = try! machine.read()!
        
        XCTAssertTrue(first.key == "hello")
        XCTAssertTrue(first.isASection == true)
        XCTAssertTrue(first.lineNumber == 1)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseSectionWithValue() {
        let machine = Reparo.StateMachine(input: "section {\nhello:world;\n}", filename: "")
        
        let section = try! machine.read()!
        
        XCTAssertTrue(section.key == "section")
        XCTAssertTrue(section.isASection == true)
        XCTAssertTrue(section.lineNumber == 1)
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "hello")
        XCTAssertTrue(line.value == "world")
        XCTAssertTrue(line.isASection == false)
        XCTAssertTrue(line.lineNumber == 2)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseMultipleSections() {
        let machine = Reparo.StateMachine(input: "hello {}\r\nworld {}", filename: "")
        
        let hello = try! machine.read()!
        
        XCTAssertTrue(hello.key == "hello")
        XCTAssertTrue(hello.isASection == true)
        XCTAssertTrue(hello.lineNumber == 1)
        
        XCTAssertNil(try! machine.read())
        
        let world = try! machine.read()!
        
        XCTAssertTrue(world.key == "world")
        XCTAssertTrue(world.isASection == true)
        XCTAssertTrue(world.lineNumber == 2)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithDirective() {
        let machine = Reparo.StateMachine(input: "hello @if DEBUG;", filename: "")
        
        let hello = try! machine.read()!
        
        XCTAssertTrue(hello.key == "hello")
        XCTAssertTrue(hello.directives.count == 1)
        XCTAssertTrue(hello.directives[0].name == "DEBUG")
        XCTAssertTrue(hello.directives[0].not == false)
        XCTAssertTrue(hello.isASection == false)
        XCTAssertTrue(hello.lineNumber == 1)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseMultipleLinesWithDirectives() {
        let machine = Reparo.StateMachine(input: "hello @if DEBUG;hello @if RELEASE;", filename: "")
        
        let debug = try! machine.read()!
        
        XCTAssertTrue(debug.key == "hello")
        XCTAssertTrue(debug.directives.count == 1)
        XCTAssertTrue(debug.directives[0].name == "DEBUG")
        XCTAssertTrue(debug.directives[0].not == false)
        
        let release = try! machine.read()!
        
        XCTAssertTrue(release.key == "hello")
        XCTAssertTrue(release.directives.count == 1)
        XCTAssertTrue(release.directives[0].name == "RELEASE")
        XCTAssertTrue(release.directives[0].not == false)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseSectionWithDirective() {
        let machine = Reparo.StateMachine(input: "hello @if !DEBUG {}", filename: "")
        
        let debug = try! machine.read()!
        
        XCTAssertTrue(debug.key == "hello")
        XCTAssertTrue(debug.directives.count == 1)
        XCTAssertTrue(debug.directives[0].name == "DEBUG")
        XCTAssertTrue(debug.directives[0].not == true)
        XCTAssertTrue(debug.isASection == true)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithMultipleDirectives() {
        let machine = Reparo.StateMachine(input: "hello: world @if DEBUG,!RELEASE;", filename: "")
        
        let debug = try! machine.read()!
        
        XCTAssertTrue(debug.key == "hello")
        XCTAssertTrue(debug.directives.count == 2)
        XCTAssertTrue(debug.directives[0].name == "DEBUG")
        XCTAssertTrue(debug.directives[0].not == false)
        XCTAssertTrue(debug.directives[1].name == "RELEASE")
        XCTAssertTrue(debug.directives[1].not == true)
        XCTAssertTrue(debug.isASection == false)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithComment() {
        let machine = Reparo.StateMachine(input: "hello; #comment", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "hello")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithMultipleComment() {
        let machine = Reparo.StateMachine(input: "#first\r\nhello { world: test; } #second", filename: "")
        
        let section = try! machine.read()!
        
        XCTAssertTrue(section.key == "hello")
        XCTAssertTrue(section.lineNumber == 2)

        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "world")
        XCTAssertTrue(line.value == "test")
        XCTAssertTrue(line.lineNumber == 2)
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithMulitlineComment() {
        let machine = Reparo.StateMachine(input: "/*first \r\n*/hello { world: test; }", filename: "")
        
        let section = try! machine.read()!
        
        XCTAssertTrue(section.key == "hello")
        XCTAssertTrue(section.lineNumber == 2)
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "world")
        XCTAssertTrue(line.value == "test")
        XCTAssertTrue(line.lineNumber == 2)
        
        XCTAssertNil(try! machine.read())
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithMultipleMulitlineComment() {
        let machine = Reparo.StateMachine(input: "/*first \r\n*/hello { /* second comment */ world: test /* third */; }", filename: "")
        
        let section = try! machine.read()!
        
        XCTAssertTrue(section.key == "hello")
        XCTAssertTrue(section.lineNumber == 2)
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "world")
        XCTAssertTrue(line.value == "test")
        XCTAssertTrue(line.lineNumber == 2)
        
        XCTAssertNil(try! machine.read())
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithDoubleQuotedValue() {
        let machine = Reparo.StateMachine(input: "first: \"hello world\";", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello world")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithDoubleQuotedValueWithLeadingAndTrailingSpaces() {
        let machine = Reparo.StateMachine(input: "first: \"  hello world  \";", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "  hello world  ")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithDoubleQuotedValueWithEmbeddedQuotes() {
        let machine = Reparo.StateMachine(input: "first: \"hello \"\" world\";", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello \" world")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithDoubleQuotesInValue() {
        let machine = Reparo.StateMachine(input: "first:  Not a valid use \" case ;", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "Not a valid use \" case")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithValuesAfterDoubleQuotedValue() {
        let machine = Reparo.StateMachine(input: "first: \"valid\" invalid;", filename: "")
        
        do {
            try machine.read()
            XCTAssertFalse(true, "Should of failed")
        } catch Reparo.ReparoError.InvalidConfigurationLine {
            XCTAssertTrue(true, "Error was thrown")
        } catch {
            XCTAssertFalse(true, "Wrong error type thrown")
        }
    }

    func testParseLineWithDoubleQuotedValueWithDirective() {
        let machine = Reparo.StateMachine(input: "first: \"hello \"\" world\" @if APPLE;", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello \" world")
        XCTAssertTrue(line.directives.count == 1)
        XCTAssertTrue(line.directives[0].name == "APPLE")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithDoubleQuotedValueWithSingleQuote() {
        let machine = Reparo.StateMachine(input: "first: \"hello ' world\";", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello ' world")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithSingleQuotedValue() {
        let machine = Reparo.StateMachine(input: "first: 'hello world';", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello world")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithSingleQuotedValueWithLeadingAndTrailingSpaces() {
        let machine = Reparo.StateMachine(input: "first: '  hello world  ';", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "  hello world  ")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithSingleQuotedValueWithEmbeddedQuotes() {
        let machine = Reparo.StateMachine(input: "first: 'hello '' world';", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello ' world")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithSingleQuotesInValue() {
        let machine = Reparo.StateMachine(input: "first:  Not a valid use ' case ;", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "Not a valid use ' case")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithValuesAfterSingleQuotedValue() {
        let machine = Reparo.StateMachine(input: "first: 'valid' invalid;", filename: "")
        
        do {
            try machine.read()
            XCTAssertFalse(true, "Should of failed")
        } catch Reparo.ReparoError.InvalidConfigurationLine {
            XCTAssertTrue(true, "Error was thrown")
        } catch {
            XCTAssertFalse(true, "Wrong error type thrown")
        }
    }
    
    func testParseLineWithSingleQuotedValueWithDirective() {
        let machine = Reparo.StateMachine(input: "first: 'hello '' world;' @if APPLE;", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello ' world;")
        XCTAssertTrue(line.directives.count == 1)
        XCTAssertTrue(line.directives[0].name == "APPLE")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWithSingleQuotedValueWithDoubleQuote() {
        let machine = Reparo.StateMachine(input: "first: 'hello \" world';", filename: "")
        
        let line = try! machine.read()!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello \" world")
        
        XCTAssertNil(try! machine.read())
    }
    
    func testParseLineWhiteSpace() {
        let input = "\n" +
        "hello;\n" +
        "world;\n" +
        "\n" +
        "again;\n" +
        "\n\n"
        
        let machine = Reparo.StateMachine(input: input, filename: "")
        
        var line = try! machine.read()!
        
        XCTAssertTrue(line.key == "hello")
        XCTAssertTrue(line.lineNumber == 2)

        line = try! machine.read()!
        
        XCTAssertTrue(line.key == "world")
        XCTAssertTrue(line.lineNumber == 3)

        line = try! machine.read()!
        
        XCTAssertTrue(line.key == "again")
        XCTAssertTrue(line.lineNumber == 5)
        
        XCTAssertNil(try! machine.read())
    }
}
