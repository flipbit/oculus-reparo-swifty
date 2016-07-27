import Quick
import Nimble
import OculusReparo

class DirectiveTransformSpec: BaseParserSpec {
    override func spec() {
        let parser = createParser()
        
        describe("when parsing lines with directives") {
            it("when parser directive is iPhone") {
                parser.directives.removeAll()
                parser.directives.append("iPhone")
                
                let config = try! parser.parseFile("Directive")
                let person = config.getSection("person")!
                
                expect(person.getValue("name")).to(equal("alice"))
            }
            
            it("when parser directive is iPad") {
                parser.directives.removeAll()
                parser.directives.append("iPad")
                
                let config = try! parser.parseFile("Directive")
                let person = config.getSection("person")!
                
                expect(person.getValue("name")).to(equal("bob"))
            }
        }
        
        describe("when parsing sections with directives") {
            it("when parser directive is iPhone") {
                parser.directives.removeAll()
                parser.directives.append("iPhone")
                
                let config = try! parser.parseFile("DirectiveSections")
                let person = config.getSection("person")!
                
                expect(person.getValue("name")).to(equal("bob"))
            }
            
            it("when parser directive is iPhone6") {
                parser.directives.removeAll()
                parser.directives.append("iPhone6")
                
                let config = try! parser.parseFile("DirectiveSections")
                let person = config.getSection("person")!
                
                expect(person.getValue("name")).to(equal("terry"))
            }
        }
        
        describe("when parsing lines with not directives") {
            it("when parser directive is iPad") {
                parser.directives.removeAll()
                parser.directives.append("iPad")
                
                let config = try! parser.parseFile("DirectiveNot")
                let person = config.getSection("person")!
                
                expect(person.getValue("name")).to(equal("alice"))
            }
            
            it("when parser has no directives") {
                parser.directives.removeAll()
                
                let config = try! parser.parseFile("DirectiveNot")
                let person = config.getSection("person")!
                
                expect(person.getValue("name")).to(equal("charles"))
            }
        }
    }
}