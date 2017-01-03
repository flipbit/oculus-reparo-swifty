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
                
                expect(first.getString("font-weight")).to(equal("bold"))
            }
        }
        
        describe("when parsing multiple includes") {
            it("include is rendered") {
                let config = try! parser.parseFile("MultipleIncludeFile")
                let sections = config.getSections("first")
                
                expect(sections.count).to(equal(5))
                
                expect(sections[0].getString("font-weight")).to(equal("bold"))
                expect(sections[1].getString("font-weight")).to(equal("bold"))
                expect(sections[2].getString("font-weight")).to(equal("bold"))
                expect(sections[3].getString("font-weight")).to(equal("bold"))
                expect(sections[4].getString("font-weight")).to(equal("bold"))
                
                config.debug()
            }
        }
        
        describe("when parsing nested includes") {
            it("include is rendered") {
                let config = try! parser.parseFile("NestedIncludeFile")
                let sections = config.getSections("first")
                
                expect(sections.count).to(equal(6))
                
                expect(sections[0].getString("font-weight")).to(equal("bold"))
                expect(sections[1].getString("font-weight")).to(equal("bold"))
                expect(sections[2].getString("font-weight")).to(equal("bold"))
                expect(sections[3].getString("font-weight")).to(equal("bold"))
                expect(sections[4].getString("font-weight")).to(equal("bold"))
                expect(sections[5].getString("font-weight")).to(equal("bold"))
                
                config.debug()
            }
        }
        
        describe("when parsing recursive includes") {
            expect{ try parser.parseFile("RecursiveIncludeFile") }.to(throwError(ReparoError.recursiveIncludeDetected))
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
