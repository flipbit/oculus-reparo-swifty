//
//  OculusReparoTests.swift
//  OculusReparoTests
//
//  Created by Chris on 06/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import XCTest
import OculusReparo

class StateMachineTests: XCTestCase {
    func testParseLine() {
        let machine = StateMachine(input: "hello;", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "hello")
        XCTAssertTrue(line.lineNumber == 1)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseMultipleLines() {
        let machine = StateMachine(input: "hello;world;", filename: "")
        
        let hello = try! machine.read().line!
        
        XCTAssertTrue(hello.key == "hello")
        XCTAssertTrue(hello.lineNumber == 1)
        
        let world = try! machine.read().line!
        
        XCTAssertTrue(world.key == "world")
        XCTAssertTrue(world.lineNumber == 1)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseMultipleLinesWithWindowsNewlines() {
        let machine = StateMachine(input: "hello;\r\nworld;", filename: "")
        
        let hello = try! machine.read().line!
        
        XCTAssertTrue(hello.key == "hello")
        XCTAssertTrue(hello.lineNumber == 1)
        
        let world = try! machine.read().line!
        
        XCTAssertTrue(world.key == "world")
        XCTAssertTrue(world.lineNumber == 2)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithValue() {
        let machine = StateMachine(input: "hello: world;", filename: "")
        
        let hello = try! machine.read().line!
        
        XCTAssertTrue(hello.key == "hello")
        XCTAssertTrue(hello.value == "world")
        XCTAssertTrue(hello.lineNumber == 1)
        XCTAssertFalse(hello.quoted)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseMultipleLinesWithValue() {
        let machine = StateMachine(input: "hello: world;\nsecond: line;", filename: "")
        
        let first = try! machine.read().line!
        
        XCTAssertTrue(first.key == "hello")
        XCTAssertTrue(first.value == "world")
        XCTAssertTrue(first.lineNumber == 1)

        let second = try! machine.read().line!
        
        XCTAssertTrue(second.key == "second")
        XCTAssertTrue(second.value == "line")
        XCTAssertTrue(second.lineNumber == 2)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseSection() {
        let machine = StateMachine(input: "hello {}", filename: "")
        
        let first = try! machine.read().line!
        
        XCTAssertTrue(first.key == "hello")
        XCTAssertTrue(first.isASection == true)
        XCTAssertTrue(first.lineNumber == 1)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseSectionWithValue() {
        let machine = StateMachine(input: "section {\nhello:world;\n}", filename: "")
        
        let section = try! machine.read().line!
        
        XCTAssertTrue(section.key == "section")
        XCTAssertTrue(section.isASection == true)
        XCTAssertTrue(section.lineNumber == 1)
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "hello")
        XCTAssertTrue(line.value == "world")
        XCTAssertTrue(line.isASection == false)
        XCTAssertTrue(line.lineNumber == 2)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseMultipleSections() {
        let machine = StateMachine(input: "hello {}\r\nworld {}", filename: "")
        
        let hello = try! machine.read().line!
        
        XCTAssertTrue(hello.key == "hello")
        XCTAssertTrue(hello.isASection == true)
        XCTAssertTrue(hello.lineNumber == 1)
        
        XCTAssertTrue(try! machine.read().endOfSection)
        
        let world = try! machine.read().line!
        
        XCTAssertTrue(world.key == "world")
        XCTAssertTrue(world.isASection == true)
        XCTAssertTrue(world.lineNumber == 2)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithDirective() {
        let machine = StateMachine(input: "hello @if DEBUG;", filename: "")
        
        let hello = try! machine.read().line!
        
        XCTAssertTrue(hello.key == "hello")
        XCTAssertTrue(hello.directives.count == 1)
        XCTAssertTrue(hello.directives[0].name == "DEBUG")
        XCTAssertTrue(hello.directives[0].not == false)
        XCTAssertTrue(hello.isASection == false)
        XCTAssertTrue(hello.lineNumber == 1)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseMultipleLinesWithDirectives() {
        let machine = StateMachine(input: "hello @if DEBUG;hello @if RELEASE;", filename: "")
        
        let debug = try! machine.read().line!
        
        XCTAssertTrue(debug.key == "hello")
        XCTAssertTrue(debug.directives.count == 1)
        XCTAssertTrue(debug.directives[0].name == "DEBUG")
        XCTAssertTrue(debug.directives[0].not == false)
        
        let release = try! machine.read().line!
        
        XCTAssertTrue(release.key == "hello")
        XCTAssertTrue(release.directives.count == 1)
        XCTAssertTrue(release.directives[0].name == "RELEASE")
        XCTAssertTrue(release.directives[0].not == false)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseSectionWithDirective() {
        let machine = StateMachine(input: "hello @if !DEBUG {}", filename: "")
        
        let debug = try! machine.read().line!
        
        XCTAssertTrue(debug.key == "hello")
        XCTAssertTrue(debug.directives.count == 1)
        XCTAssertTrue(debug.directives[0].name == "DEBUG")
        XCTAssertTrue(debug.directives[0].not == true)
        XCTAssertTrue(debug.isASection == true)
        
        XCTAssertTrue(try! machine.read().endOfSection)
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithMultipleDirectives() {
        let machine = StateMachine(input: "hello: world @if DEBUG,!RELEASE;", filename: "")
        
        let debug = try! machine.read().line!
        
        XCTAssertTrue(debug.key == "hello")
        XCTAssertTrue(debug.directives.count == 2)
        XCTAssertTrue(debug.directives[0].name == "DEBUG")
        XCTAssertTrue(debug.directives[0].not == false)
        XCTAssertTrue(debug.directives[1].name == "RELEASE")
        XCTAssertTrue(debug.directives[1].not == true)
        XCTAssertTrue(debug.isASection == false)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithComment() {
        let machine = StateMachine(input: "hello; #comment", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "hello")
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithMultipleComment() {
        let machine = StateMachine(input: "#first\r\nhello { world: test; } #second", filename: "")
        
        let section = try! machine.read().line!
        
        XCTAssertTrue(section.key == "hello")
        XCTAssertTrue(section.lineNumber == 2)

        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "world")
        XCTAssertTrue(line.value == "test")
        XCTAssertTrue(line.lineNumber == 2)
        
        XCTAssertTrue(try! machine.read().endOfSection)
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithMulitlineComment() {
        let machine = StateMachine(input: "/*first \r\n*/hello { world: test; }", filename: "")
        
        let section = try! machine.read().line!
        
        XCTAssertTrue(section.key == "hello")
        XCTAssertTrue(section.lineNumber == 2)
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "world")
        XCTAssertTrue(line.value == "test")
        XCTAssertTrue(line.lineNumber == 2)
        
        XCTAssertTrue(try! machine.read().endOfSection)
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithMultipleMulitlineComment() {
        let machine = StateMachine(input: "/*first \r\n*/hello { /* second comment */ world: test /* third */; }", filename: "")
        
        let section = try! machine.read().line!
        
        XCTAssertTrue(section.key == "hello")
        XCTAssertTrue(section.lineNumber == 2)
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "world")
        XCTAssertTrue(line.value == "test")
        XCTAssertTrue(line.lineNumber == 2)
        
        XCTAssertTrue(try! machine.read().endOfSection)
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithDoubleQuotedValue() {
        let machine = StateMachine(input: "first: \"hello world\";", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello world")
        XCTAssertTrue(line.quoted)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithDoubleQuotedValueWithLeadingAndTrailingSpaces() {
        let machine = StateMachine(input: "first: \"  hello world  \";", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "  hello world  ")
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithDoubleQuotedValueWithEmbeddedQuotes() {
        let machine = StateMachine(input: "first: \"hello \"\" world\";", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello \" world")
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithDoubleQuotesInValue() {
        let machine = StateMachine(input: "first:  Not a valid use \" case ;", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "Not a valid use \" case")
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithValuesAfterDoubleQuotedValue() {
        let machine = StateMachine(input: "first: \"valid\" invalid;", filename: "")
        
        do {
            try machine.read()
            XCTAssertFalse(true, "Should of failed")
        } catch ReparoError.InvalidConfigurationLine {
            XCTAssertTrue(true, "Error was thrown")
        } catch {
            XCTAssertFalse(true, "Wrong error type thrown")
        }
    }

    func testParseLineWithDoubleQuotedValueWithDirective() {
        let machine = StateMachine(input: "first: \"hello \"\" world\" @if APPLE;", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello \" world")
        XCTAssertTrue(line.directives.count == 1)
        XCTAssertTrue(line.directives[0].name == "APPLE")
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithDoubleQuotedValueWithSingleQuote() {
        let machine = StateMachine(input: "first: \"hello ' world\";", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello ' world")
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithSingleQuotedValue() {
        let machine = StateMachine(input: "first: 'hello world';", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello world")
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithSingleQuotedValueWithLeadingAndTrailingSpaces() {
        let machine = StateMachine(input: "first: '  hello world  ';", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "  hello world  ")
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithSingleQuotedValueWithEmbeddedQuotes() {
        let machine = StateMachine(input: "first: 'hello '' world';", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello ' world")
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithSingleQuotesInValue() {
        let machine = StateMachine(input: "first:  Not a valid use ' case ;", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "Not a valid use ' case")
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithValuesAfterSingleQuotedValue() {
        let machine = StateMachine(input: "first: 'valid' invalid;", filename: "")
        
        do {
            try machine.read()
            XCTAssertFalse(true, "Should of failed")
        } catch ReparoError.InvalidConfigurationLine {
            XCTAssertTrue(true, "Error was thrown")
        } catch {
            XCTAssertFalse(true, "Wrong error type thrown")
        }
    }
    
    func testParseLineWithSingleQuotedValueWithDirective() {
        let machine = StateMachine(input: "first: 'hello '' world;' @if APPLE;", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello ' world;")
        XCTAssertTrue(line.directives.count == 1)
        XCTAssertTrue(line.directives[0].name == "APPLE")
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWithSingleQuotedValueWithDoubleQuote() {
        let machine = StateMachine(input: "first: 'hello \" world';", filename: "")
        
        let line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.value == "hello \" world")
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
    
    func testParseLineWhiteSpace() {
        let input = "\n" +
        "hello;\n" +
        "world;\n" +
        "\n" +
        "again;\n" +
        "\n\n"
        
        let machine = StateMachine(input: input, filename: "")
        
        var line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "hello")
        XCTAssertTrue(line.lineNumber == 2)

        line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "world")
        XCTAssertTrue(line.lineNumber == 3)

        line = try! machine.read().line!
        
        XCTAssertTrue(line.key == "again")
        XCTAssertTrue(line.lineNumber == 5)
        
        XCTAssertTrue(try! machine.read().endOfDocument)
    }
}
