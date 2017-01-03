open class LayoutViewFragment : LayoutFragment {
    open var view: UIView
    
    public init(view: UIView, id: String, configuration: Section) {
        self.view = view
        
        super.init(id: id, configuration: configuration)
    }
}
