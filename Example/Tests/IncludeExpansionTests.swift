import Quick
import Nimble
import OculusReparo

class IncludeExpansionSpec: BaseParserSpec {
    override func spec() {
        let parser = createParser()
        
        describe("when parsing single include") {
            it("include is rendered") {
                let config = try! parser.parseFile("SingleIncludeFile")
                config.debug()
                let first = config.getSection("first")!
                
                expect(first.getValue("font-weight")).to(equal("bold"))
            }
        }
        
        describe("when parsing multiple includes") {
            it("include is rendered") {
                let config = try! parser.parseFile("MultipleIncludeFile")
                let sections = config.getSections("first")
                
                expect(sections.count).to(equal(5))
                
                expect(sections[0].getValue("font-weight")).to(equal("bold"))
                expect(sections[1].getValue("font-weight")).to(equal("bold"))
                expect(sections[2].getValue("font-weight")).to(equal("bold"))
                expect(sections[3].getValue("font-weight")).to(equal("bold"))
                expect(sections[4].getValue("font-weight")).to(equal("bold"))
                
                config.debug()
            }
        }
        
        describe("when parsing nested includes") {
            it("include is rendered") {
                let config = try! parser.parseFile("NestedIncludeFile")
                let sections = config.getSections("first")
                
                expect(sections.count).to(equal(6))
                
                expect(sections[0].getValue("font-weight")).to(equal("bold"))
                expect(sections[1].getValue("font-weight")).to(equal("bold"))
                expect(sections[2].getValue("font-weight")).to(equal("bold"))
                expect(sections[3].getValue("font-weight")).to(equal("bold"))
                expect(sections[4].getValue("font-weight")).to(equal("bold"))
                expect(sections[5].getValue("font-weight")).to(equal("bold"))
                
                config.debug()
            }
        }
        
        describe("when parsing recursive includes") {
            expect{ try parser.parseFile("RecursiveIncludeFile") }.to(throwError(ReparoError.RecursiveIncludeDetected))
            /*
            do {
                try
                XCTAssertTrue(false, "Should of failed")
            } catch  {
                XCTAssertTrue(true)
            } catch {
                XCTAssertTrue(false, "Wrong error thrown")
            }
            */
        }
    }
}