import Quick
import Nimble
import OculusReparo

class EachTransformSpec: BaseParserSpec {
    override func spec() {
        let parser = createParser()
        
        describe("when parsing an each loop") {
            it("is iterated for a string array") {
                parser.variables["names"] = ["alice", "bob", "sue"]
                
                let config = try! parser.parseFile("Each")
                
                config.debug()
                
                expect(config.lines.count).to(equal(3))
                
                expect(config.lines[0].value).to(equal("alice"))
                expect(config.lines[1].value).to(equal("bob"))
                expect(config.lines[2].value).to(equal("sue"))                
            }
            
            it("is iterated for a complex model") {
                parser.variables["persons"] =
                    [Model(name: "alice", age: 10),
                     Model(name: "bob", age: 20),
                     Model(name: "sue", age: 30)]
                
                let config = try! parser.parseFile("EachComplex")
                
                config.debug()
                
                let persons = config.getSections("person")
                
                expect(persons.count).to(equal(3))
                
                expect(persons[0].getValue("name")).to(equal("alice"))
                expect(persons[0].getValue("age")).to(equal("10"))
                expect(persons[1].getValue("name")).to(equal("bob"))
                expect(persons[1].getValue("age")).to(equal("20"))
                expect(persons[2].getValue("name")).to(equal("sue"))
                expect(persons[2].getValue("age")).to(equal("30"))
            }

        }
    }
    
    class Model : NSObject {
        var name: String
        var age: Int
        
        init(name: String, age: Int) {
            self.name = name
            self.age = age
        }
    }
}