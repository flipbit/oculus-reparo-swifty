import XCTest
@testable import OculusReparo

class ReparoIncludeTransformTests: XCTestCase {
    private var parser: Reparo.Parser?
    
    override func setUp() {
        super.setUp()
        
        parser = Reparo.Parser(reader: SampleReader())
    }
    
    func testParseSingleIncludeSection() {
        let config = try! parser?.parseFile("SingleIncludeFile.txt")
        let first = config!.getSection("first")!
        
        XCTAssertTrue(first.getValue("font-weight") == "bold")
    }
    
    func testParseMultipleIncludeSection() {
        let config = try! parser?.parseFile("MultipleIncludeFile.txt")
        let sections = config!.getSections("first")
        
        XCTAssertTrue(sections.count == 5)
        XCTAssertTrue(sections[0].getValue("font-weight") == "bold")
        XCTAssertTrue(sections[1].getValue("font-weight") == "bold")
        XCTAssertTrue(sections[2].getValue("font-weight") == "bold")
        XCTAssertTrue(sections[3].getValue("font-weight") == "bold")
        XCTAssertTrue(sections[4].getValue("font-weight") == "bold")
    }
    
    func testParseNestedIncludeSection() {
        let config = try! parser?.parseFile("NestedIncludeFile.txt")
        let sections = config!.getSections("first")
        
        XCTAssertTrue(sections.count == 6)
        XCTAssertTrue(sections[0].getValue("font-weight") == "bold")
        XCTAssertTrue(sections[1].getValue("font-weight") == "bold")
        XCTAssertTrue(sections[2].getValue("font-weight") == "bold")
        XCTAssertTrue(sections[3].getValue("font-weight") == "bold")
        XCTAssertTrue(sections[4].getValue("font-weight") == "bold")
        XCTAssertTrue(sections[5].getValue("font-weight") == "bold")
    }
    
    func testParseRecursiveIncludeSection() {
        do {
            try parser?.parseFile("RecursiveIncludeFile.txt")
            XCTAssertTrue(false, "Should of failed")
        } catch Reparo.ReparoError.RecursiveIncludeDetected {
            XCTAssertTrue(true)
        } catch {
            XCTAssertTrue(false, "Wrong error thrown")
        }
    }
}