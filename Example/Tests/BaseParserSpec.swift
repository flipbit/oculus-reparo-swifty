import Quick
import Nimble
import OculusReparo

class BaseParserSpec: QuickSpec {
    func createParser() -> Parser {
        let parser = Parser()
    
        parser.reader = SampleReader()
    
        return parser
    }
}