import Quick
import Nimble
import OculusReparo

class ScopeSpec: QuickSpec {
    override func spec() {
        describe("when a scope has no directives") {
            let scope = Scope()
            
            it("is satisfied by a line with no directvies") {
                let line = Line()
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is satisfied by a line with a single not directive") {
                let line = Line()
                line.directives.append(Directive(name: "first", not: true))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is satisfied by a line with a multiple not directives") {
                let line = Line()
                line.directives.append(Directive(name: "first", not: true))
                line.directives.append(Directive(name: "second", not: true))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
        }
        
        describe("when a scope has a single directive") {
            let scope = Scope()
            scope.directives.append("first")
            
            it("is satisfied by a line with no directvies") {
                let line = Line()
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is satisfied by a line with a single included directive") {
                let line = Line()
                line.directives.append(Directive(name: "first"))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is satisfied by a line with a single not directive") {
                let line = Line()
                line.directives.append(Directive(name: "second", not: true))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is satisfied by a line with a multiple not directives") {
                let line = Line()
                line.directives.append(Directive(name: "second", not: true))
                line.directives.append(Directive(name: "third", not: true))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is not satisfied by a line when some directives are false") {
                let line = Line()
                line.directives.append(Directive(name: "second"))
                line.directives.append(Directive(name: "first"))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(false))
            }
            
            it("is not satisfied by a line when the directive is a not directive") {
                let line = Line()
                line.directives.append(Directive(name: "first", not: true))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(false))
            }
            
            it("does not matter when the directive cases are different") {
                let line = Line()
                line.directives.append(Directive(name: "FIRST"))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
        }
        
        describe("when a scope has a multiple directive") {
            let scope = Scope()
            scope.directives.append("first")
            scope.directives.append("second")
            
            it("is satisfied by a line with no directvies") {
                let line = Line()
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is satisfied by a line with only one of the directives") {
                let line = Line()
                line.directives.append(Directive(name: "first"))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is satisfied by a line with a single not directive") {
                let line = Line()
                line.directives.append(Directive(name: "third", not: true))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is satisfied by a line with a multiple not directives") {
                let line = Line()
                line.directives.append(Directive(name: "third", not: true))
                line.directives.append(Directive(name: "fourth", not: true))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is satisfied by a line with all matching directives") {
                let line = Line()
                line.directives.append(Directive(name: "second"))
                line.directives.append(Directive(name: "first"))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is not satisfied by a line when the directive is a not directive") {
                let line = Line()
                line.directives.append(Directive(name: "first", not: true))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(false))
            }
        }
        
        describe("when a scope has a 100x100 screen size") {
            let scope = Scope()
            scope.screenSize = CGRect(x: 0, y: 0, width: 100, height: 100)
            
            it("is satisfied by a line with no directvies") {
                let line = Line()
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is satisfied by a line with a width of 100") {
                let line = Line()
                line.directives.append(Directive(name: "width=100"))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(true))
            }
            
            it("is not satisfied by a line with a height of at least 200") {
                let line = Line()
                line.directives.append(Directive(name: "height>=200"))
                
                expect(try! scope.satisfiesDirectives(line)).to(equal(false))
            }
        }

    }
}
