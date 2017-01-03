import Quick
import Nimble
import OculusReparo

class ConvertSpec: QuickSpec {
    override func spec() {
        describe("convert returns") {
            it("view id and top anchor") {
                let line = try! Convert.getViewIdAndAnchor("view.top", defaultIdView: "view", defaultAnchor: .Top)

                expect(line.viewId).to(equal("view"))
                expect(line.anchor.rawValue).to(equal(LayoutAnchorType.Top.rawValue))
            }
            
            it("view id and bottom anchor") {
                let line = try! Convert.getViewIdAndAnchor("view.bottom", defaultIdView: "view", defaultAnchor: .Top)
                
                expect(line.viewId).to(equal("view"))
                expect(line.anchor.rawValue).to(equal(LayoutAnchorType.Bottom.rawValue))
            }
        }
    }
}
