import Quick
import Nimble
import OculusReparo

class VariableTransformSpec: BaseParserSpec {
    override func spec() {
        let parser = createParser()
        
        describe("when parsing file with variables") {
            it("variables are substituted") {
                let config = try! parser.parseFile("Variable")
                let person = config.getSection("person")!
                
                expect(person.getValue("name")).to(equal("bob"))
            }
            
            it("values in quotes are ignored") {
                let config = try! parser.parseFile("VariableQuoted")
                let person = config.getSection("person")!
                
                expect(person.getValue("name")).to(equal("@name"))
            }
        }
    }
}