import Quick
import Nimble
import OculusReparo

class LineSpec: QuickSpec {
    override func spec() {
        describe("line path") {
            it("when empty") {
                let line = OculusReparo.Line(filename: "", lineNumber: 1)
                
                expect(line.path) == "/[0]"
            }
            
            it("with an index") {
                let line = OculusReparo.Line(filename: "", lineNumber: 1)
                
                line.index = 1
                line.key = nil
                
                expect(line.path) == "/[1]"
            }
            
            it("with a key") {
                let line = OculusReparo.Line(filename: "", lineNumber: 1)
                
                line.index = 1
                line.key = "value"
                
                expect(line.path) == "/value[1]"
            }
            
            context("with a parent") {
                let line = OculusReparo.Line(filename: "", lineNumber: 1)

                line.index = 1
                line.key = "child"
                
                let parent = OculusReparo.Section(filename: "")
                parent.key = "parent"
                parent.index = 2
                parent.addLine(line)
                
                it("has parents path prepended") {
                    expect(line.path) == "/parent[2]/child[1]"
                }
            }
        }
        
        describe("when cloned") {
            it("is not the same") {
                let line = OculusReparo.Line(filename: "", lineNumber: 1)
                let clone = line.clone()
                
                expect(line === clone).toNot(equal(true))
            }
            
            it("has the same properties") {
                let line = OculusReparo.Line(filename: "", lineNumber: 1)
                line.index = 5
                line.key = "key"
                line.value = "value"
                
                let clone = line.clone()
                
                expect(clone.index).to(equal(5))
                expect(clone.key).to(equal("key"))
                expect(clone.value).to(equal("value"))
            }
        }
    }
}
