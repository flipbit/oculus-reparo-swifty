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
                
                expect(person.getString("name")).to(equal("bob"))
            }
            
            it("values in quotes are ignored") {
                let config = try! parser.parseFile("VariableQuoted")
                let person = config.getSection("person")!
                
                expect(person.getString("name")).to(equal("@name"))
            }
            
            it("complex values are parsed") {
                parser.variables.removeAll()
                parser.variables["person"] = Model(name: "jude")
                
                let config = try! parser.parseFile("VariableComplex")
                
                expect(config.getString("name")).to(equal("jude"))
            }
        }
    }
    
    class Model : NSObject {
        var name: String
        
        init(name: String) {
            self.name = name
        }
    }
}
