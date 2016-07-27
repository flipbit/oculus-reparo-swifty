import Quick
import Nimble
import OculusReparo

class FunctionTransformSpec: BaseParserSpec {
    override func spec() {
        let parser = createParser()
        
        describe("when parsing file with function") {
            it("functions are substituted") {
                let config = try! parser.parseFile("Function")
                let persons = config.getSections("person")
                
                expect(persons.count).to(equal(2))
                
                let bob = persons[0]
                
                expect(bob.getValue("name")).to(equal("bob"))
                
                let alice = persons[1]
                
                expect(alice.getValue("name")).to(equal("alice"))
                
                config.debug()
            }
        }
    }
}