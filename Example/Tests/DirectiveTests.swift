import Quick
import Nimble
import OculusReparo

class DirectiveSpec: QuickSpec {
    override func spec() {
        describe("a directive") {
            it("is not a resolution directive") {
                let directive = Directive(name: "first")
                
                expect(directive.isResolutionDirective).to(equal(false))
            }
            
            it("is a width resolution directive") {
                let directive = Directive(name: "width > 100")
                
                expect(directive.isResolutionDirective).to(equal(true))
            }
            
            it("is a height resolution directive") {
                let directive = Directive(name: "height = 100")
                
                expect(directive.isResolutionDirective).to(equal(true))
            }
            
            it("is a not a resolution directive when in invalid format") {
                let directive = Directive(name: "height")
                
                expect(directive.isResolutionDirective).to(equal(false))
            }
            
            it("returns the correct resolution parts") {
                var parts = try! Directive(name: "height = 100").getResolutionParts()
                
                expect(parts.dimension).to(equal(Directive.Dimension.height))
                expect(parts.equality).to(equal(Directive.Equality.equal))
                expect(parts.value).to(equal(100))
                
                parts = try! Directive(name: "width == 250.0").getResolutionParts()
                
                expect(parts.dimension).to(equal(Directive.Dimension.width))
                expect(parts.equality).to(equal(Directive.Equality.equal))
                expect(parts.value).to(equal(250))
                
                parts = try! Directive(name: "width <= 1.1").getResolutionParts()
                
                expect(parts.dimension).to(equal(Directive.Dimension.width))
                expect(parts.equality).to(equal(Directive.Equality.lessThanOrEqual))
                expect(parts.value).to(equal(1.1))
                
                parts = try! Directive(name: "width < 1").getResolutionParts()
                
                expect(parts.dimension).to(equal(Directive.Dimension.width))
                expect(parts.equality).to(equal(Directive.Equality.lessThan))
                expect(parts.value).to(equal(1))
                
                parts = try! Directive(name: "width >= 2").getResolutionParts()
                
                expect(parts.dimension).to(equal(Directive.Dimension.width))
                expect(parts.equality).to(equal(Directive.Equality.greaterThanOrEqual))
                expect(parts.value).to(equal(2))
                
                parts = try! Directive(name: "width>3").getResolutionParts()
                
                expect(parts.dimension).to(equal(Directive.Dimension.width))
                expect(parts.equality).to(equal(Directive.Equality.greaterThan))
                expect(parts.value).to(equal(3))
            }
            
            it("is satisfied by resolution height") {
                let directive = Directive(name: "height = 100")

                expect(try! directive.satisfiedBy(CGSize(width: 100, height: 100))).to(equal(true))
            }
            
            it("is satisfied by resolution width") {
                let directive = Directive(name: "width > 100")
                
                expect(try! directive.satisfiedBy(CGSize(width: 200, height: 100))).to(equal(true))
            }
            
            it("is not satisfied by resolution height") {
                let directive = Directive(name: "height <= 100")
                
                expect(try! directive.satisfiedBy(CGSize(width: 100, height: 200))).to(equal(false))
            }
            
            it("is not satisfied by resolution width") {
                let directive = Directive(name: "width >= 100")
                
                expect(try! directive.satisfiedBy(CGSize(width: 50, height: 100))).to(equal(false))
            }
            
            it("is not satisfied by resolution width") {
                let directive = Directive(name: "width < 1000")
                
                expect(try! directive.satisfiedBy(CGSize(width: 1000, height: 100))).to(equal(false))
            }
        }
    }
}
