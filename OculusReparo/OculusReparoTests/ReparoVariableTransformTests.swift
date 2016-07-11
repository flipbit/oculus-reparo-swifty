import XCTest
@testable import OculusReparo

class ReparoVariableTransformTests: XCTestCase {
    private var parser: Reparo.Parser?
    
    override func setUp() {
        super.setUp()
        
        parser = Reparo.Parser()
    }
    
    func testParseSingleEmptySection() {
        let config = try! parser?.parseString(sample("Variable"), filename: "")
        let line = config!.sections[0]
        
        XCTAssertTrue(line.key == "person")
        XCTAssertTrue(line.getValue("name") == "bob")
    }
    

    
    func sample(filename: String) -> String {
        let path = NSBundle(forClass: self.dynamicType).resourcePath! + "/\(filename).txt"
        return try! NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
    }
}
