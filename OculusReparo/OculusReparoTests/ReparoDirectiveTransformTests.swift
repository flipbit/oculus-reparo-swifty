import XCTest
@testable import OculusReparo

class ReparoDirectiveTransformTests: XCTestCase {
    private var parser: Reparo.Parser?
    
    override func setUp() {
        super.setUp()
        
        parser = Reparo.Parser()
    }
    
    func testParseSingleDirectiveOne() {
        parser?.directives.append("iPhone")
        
        let config = try! parser?.parseString(sample("Directive"), filename: "")
        let line = config!.sections[0]
        
        XCTAssertTrue(line.key == "person")
        XCTAssertTrue(line.getValue("name") == "alice")
    }
    
    func testParseSingleDirectiveTwo() {
        parser?.directives.append("iPad")
        
        let config = try! parser?.parseString(sample("Directive"), filename: "")
        let line = config!.sections[0]
        
        XCTAssertTrue(line.key == "person")
        XCTAssertTrue(line.getValue("name") == "bob")
    }

    func testPath() {
        parser?.directives.append("iPad")
        
        let document =  try! parser?.parseString(sample("Directive"), filename: "", runTransforms: false)
        let transformed = try! parser?.transform(document!)
        
        let bob = transformed!.getSection("person")
        let path = bob!.lines[0].path
        
        XCTAssertTrue(path == "/person[1]/name[2]")
        XCTAssertTrue(bob!.getValue("name") == "bob")
    }
    
    
    func sample(filename: String) -> String {
        let path = NSBundle(forClass: self.dynamicType).resourcePath! + "/\(filename).txt"
        return try! NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
    }
}
