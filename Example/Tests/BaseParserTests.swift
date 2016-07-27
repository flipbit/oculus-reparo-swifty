import OculusReparo
import XCTest

class BaseParserTests: XCTestCase {
    var parser = Parser()
    
    override func setUp() {
        super.setUp()
        
        parser = Parser()
        parser.reader = SampleReader()
    }
}