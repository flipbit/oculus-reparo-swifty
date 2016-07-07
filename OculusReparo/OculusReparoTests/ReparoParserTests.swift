import XCTest
@testable import OculusReparo

class ReparoParserTests: XCTestCase {
    private var parser: Reparo.Parser?
    
    override func setUp() {
        super.setUp()
        
        parser = Reparo.Parser()
    }
    
    func testParseEmptyString() {
        let lines = try! parser?.parseString("", filename: "")
        
        XCTAssertTrue(lines!.count == 0)
    }
    
    func testParseSingleEmptySection() {
        let lines = try! parser?.parseString(sample("SingleEmptySection"), filename: "")
        
        XCTAssertTrue(lines!.count == 1)
        XCTAssertTrue(lines![0].key == "first")
        XCTAssertTrue(lines![0].isASection == true)
    }
    
    func testParseSingleEmptySectionAlternateFormat() {
        let lines = try! parser?.parseString(sample("SingleEmptySectionAlternate"), filename: "")
        
        XCTAssertTrue(lines!.count == 1)
        XCTAssertTrue(lines![0].key == "first")
    }
    
    func testParseMultipleEmptySections() {
        let lines = try! parser?.parseString(sample("MultipleEmptySection"), filename: "")
        
        XCTAssertTrue(lines!.count == 3)
        XCTAssertTrue(lines![0].key == "first")
        XCTAssertTrue(lines![1].key == "second")
        XCTAssertTrue(lines![2].key == "third")
    }
    
    func testParseMultipleEmptySectionsAlternateFormat() {
        let lines = try! parser?.parseString(sample("MultipleEmptySectionAlternate"), filename: "")
        
        XCTAssertTrue(lines!.count == 3)
        XCTAssertTrue(lines![0].key == "first")
        XCTAssertTrue(lines![1].key == "second")
        XCTAssertTrue(lines![2].key == "third")
    }

    func testParseSingleSectionWithValue() {
        let lines = try! parser?.parseString(sample("SingleSection"), filename: "")
        
        let section = lines![0] as! Reparo.Section
        
        XCTAssertTrue(section.key == "first")
        XCTAssertTrue(section.lines.count == 1)
        XCTAssertTrue(section.lines[0].key = "font-weight")
        XCTAssertTrue(section.lines[0].value = "bold")
    }

    
    func sample(filename: String) -> String {
        let path = NSBundle(forClass: self.dynamicType).resourcePath! + "/\(filename).txt"
        return try! NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
    }
}
