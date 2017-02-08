import Foundation

open class UIWebViewBuilder : ViewBuilder {
    override open func canBuild(_ layout: Section) -> Bool {
        return layout.key == "web"
    }
    
    override open func build(_ layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let webView: UIWebView = try initialize(layout, instance: instance, parent: parent)
        
        return webView;
    }
}
