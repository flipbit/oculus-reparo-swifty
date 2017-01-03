open class LayoutFragment {
    open var configuration: Section
    open var id: String
    
    public init(id: String, configuration: Section) {
        self.id = id
        self.configuration = configuration
    }
}
