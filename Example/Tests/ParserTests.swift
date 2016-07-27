import XCTest
import OculusReparo

class ParserTests: BaseParserTests {
    func testParseEmptyString() {
        let config = try! parser.parseString("", filename: "")
        let lines = config.lines
        
        XCTAssertTrue(lines.count == 0)
    }
    
    func testParseSingleEmptySection() {
        let config = try! parser.parseFile("SingleEmptySection")
        let line = config.lines[0]
        
        XCTAssertTrue(config.lines.count == 1)
        XCTAssertTrue(line.key == "first")
        XCTAssertTrue(line.isASection == true)
    }
    
    func testParseSingleEmptySectionAlternateFormat() {
        let config = try! parser.parseFile("SingleEmptySectionAlternate")
        let lines = config.lines
        
        XCTAssertTrue(lines.count == 1)
        XCTAssertTrue(lines[0].key == "first")
    }
    
    func testParseMultipleEmptySections() {
        let config = try! parser.parseFile("MultipleEmptySection")
        let lines = config.lines
        
        XCTAssertTrue(lines.count == 3)
        XCTAssertTrue(lines[0].key == "first")
        XCTAssertTrue(lines[1].key == "second")
        XCTAssertTrue(lines[2].key == "third")
    }
    
    func testParseMultipleEmptySectionsAlternateFormat() {
        let config = try! parser.parseFile("MultipleEmptySectionAlternate")
        let lines = config.lines
        
        XCTAssertTrue(lines.count == 3)
        XCTAssertTrue(lines[0].key == "first")
        XCTAssertTrue(lines[1].key == "second")
        XCTAssertTrue(lines[2].key == "third")
    }

    func testParseSingleSectionWithValue() {
        let config = try! parser.parseFile("SingleSection")
        let lines = config.lines
        
        let section = lines[0] as! Section
        
        XCTAssertTrue(section.key == "first")
        XCTAssertTrue(section.lines.count == 1)
        XCTAssertTrue(section.lines[0].key == "font-weight")
        XCTAssertTrue(section.lines[0].value == "bold")
    }
    
    func testParseSingleSectionWithMultipleValues() {
        let config = try! parser.parseFile("SingleSectionMultipleValues")
        let lines = config.lines
        
        let section = lines[0] as! Section
        
        XCTAssertTrue(section.key == "first")
        XCTAssertTrue(section.lines.count == 2)
        XCTAssertTrue(section.lines[0].key == "font-weight")
        XCTAssertTrue(section.lines[0].value == "bold")
        XCTAssertTrue(section.lines[1].key == "text-align")
        XCTAssertTrue(section.lines[1].value == "center")
    }
    
    func testParseSingleSectionWithSubsection() {
        let config = try! parser.parseFile("SingleSectionWithSubsection")
        let lines = config.lines
        
        let first = lines[0] as! Section
        let second = first.sections[0]
        
        XCTAssertTrue(first.key == "first")
        XCTAssertTrue(second.key == "second")
        XCTAssertTrue(second.lines[0].key == "font-size")
        XCTAssertTrue(second.lines[0].value == "12")
    }
    
    func testParseSingleSectionWithMultipleSubsection() {
        let config = try! parser.parseFile("SingleSectionWithMultipleSubsection")
        
        let second = config.getSection("second", recurse: true)
        let third = config.getSection("third", recurse: true)
        let fourth = config.getSection("fourth", recurse: true)
        
        XCTAssertTrue(second?.lines[0].key == "font-size")
        XCTAssertTrue(second?.lines[0].value == "12")
        XCTAssertTrue(third?.lines[0].key == "font-size")
        XCTAssertTrue(third?.lines[0].value == "13")
        XCTAssertTrue(fourth?.lines[0].key == "font-size")
        XCTAssertTrue(fourth?.lines[0].value == "14")
    }
    
    func testParseCommentLines() {
        let config = try! parser.parseFile("SingleSectionWithComments")
        
        XCTAssertTrue(config.lines.count == 1)
    }
    
    func testParseInvalidLine() {
        do {
            try parser.parseFile("InvalidLineInRoot")
            XCTAssertFalse(true, "Should of failed")
        } catch ReparoError.InvalidConfigurationLine {
            XCTAssertTrue(true, "Error was thrown")
        } catch {
            XCTAssertFalse(true, "Wrong error type thrown")
        }
    }
    
    func testParseInvalidLineInSection() {
        do {
            try parser.parseFile("InvalidLineInSection")
            XCTAssertFalse(true, "Should of failed")
        } catch ReparoError.InvalidConfigurationLine {
            XCTAssertTrue(true, "Error was thrown")
        } catch {
            XCTAssertFalse(true, "Wrong error type thrown")
        }
    }
}
