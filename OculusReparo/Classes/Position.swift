import Foundation

open class Position {
    public enum HorizontalAlignment : String {
        case Left = "left"
        case Center = "center"
        case Right = "right"
    }
    
    public enum VerticalAlignment : String {
        case Top = "top"
        case Middle = "middle"
        case Bottom = "bottom"
    }
    
    fileprivate var parentView: UIView?
    fileprivate var parentLayer: CALayer?
    
    fileprivate var parentFrame: CGRect {
        if parentView != nil {
            return parentView!.frame
        } else {
            return parentLayer!.frame
        }
    }
    
    var top: String?
    var left: String?
    var width: String?
    var height: String?
    var horizontalAlignment: HorizontalAlignment
    var verticalAlignment: VerticalAlignment
    
    var paddingTop: String?
    var paddingLeft: String?
    var paddingRight: String?
    var paddingBottom: String?

    var offsetTop: String?
    var offsetLeft: String?
    var offsetWidth: String?
    var offsetHeight: String?

    init() {
        top = "0"
        left = "0"
        width = "100%"
        height = "100%"
        horizontalAlignment = HorizontalAlignment.Left
        verticalAlignment = VerticalAlignment.Top
    }
    
    convenience init(parent: UIView) {
        self.init()
        
        parentView = parent
    }
    
    convenience init(parent: CALayer) {
        self.init()
        
        parentLayer = parent
    }
    
    convenience init(section: Section, parent: CALayer) throws {
        try self.init(section: section)
        
        parentLayer = parent
    }
    
    convenience init(section: Section, parent: UIView) throws {
        try self.init(section: section)
        
        parentView = parent
    }
    
    init(section: Section) throws {
        top = section.getString("top", ifMissing: "0")
        left = section.getString("left", ifMissing: "0")
        width = section.getString("width", ifMissing: "100%")
        height = section.getString("height", ifMissing: "100%")
        
        if let align = section.getString("horizontal-align", ifMissing: "left") {
            horizontalAlignment = HorizontalAlignment(rawValue: align)!
        } else {
            horizontalAlignment = HorizontalAlignment.Left
        }
        
        if let align = section.getString("vertical-align", ifMissing: "top") {
            verticalAlignment = VerticalAlignment(rawValue: align)!
        } else {
            verticalAlignment = VerticalAlignment.Top
        }
        
        if let padding = section.getString("padding") {
            let padding = try Convert.getPadding(padding)
            
            paddingTop = padding.top
            paddingLeft = padding.left
            paddingBottom = padding.bottom
            paddingRight = padding.right
        }
        
        paddingTop = section.getString("padding-top", ifMissing: paddingTop)
        paddingLeft = section.getString("padding-left", ifMissing: paddingLeft)
        paddingRight = section.getString("padding-right", ifMissing: paddingRight)
        paddingBottom = section.getString("padding-bottom", ifMissing: paddingBottom)

        if let offset = section.getString("offset") {
            let offset = try Convert.getOffset(offset)
            
            offsetTop = offset.top
            offsetLeft = offset.left
            offsetWidth = offset.width
            offsetHeight = offset.height
        }
        
        offsetTop = section.getString("offset-top", ifMissing: offsetTop)
        offsetLeft = section.getString("offset-left", ifMissing: offsetLeft)
        offsetWidth = section.getString("offset-width", ifMissing: offsetWidth)
        offsetHeight = section.getString("offset-height", ifMissing: offsetHeight)
        
        if let alignment = section.getString("align") {
            setAlignment(alignment)
        }
        
        if !section.hasValue("width") && section.parent!.hasValue("snap-right") {
            width = "0"
        }
 
        if !section.hasValue("top") && section.parent!.hasValue("snap-top") {
            top = "0"
        }
    }
    
    func toFrame(_ lastSiblingFrame: CGRect) -> CGRect {
        // Get dimensions (absolute or percentage)
        var x = getDimension(left, parent: parentFrame.size.width)
        var y = getDimension(top, parent: parentFrame.size.height)
        var w = getDimension(width, parent: parentFrame.size.width)
        var h = getDimension(height, parent: parentFrame.size.height)
        
        // Set relative x value
        if left != nil && left!.hasPrefix("+") {
            x = x + lastSiblingFrame.origin.x + lastSiblingFrame.width;
        }
        
        // Set relative y value
        if top != nil && top!.hasPrefix("+") {
            y = y + lastSiblingFrame.origin.y + lastSiblingFrame.height;
        }
        
        // Set fills
        if width == "fill" {
            w = parentFrame.width - x
        }        
        if height == "fill" {
            h = parentFrame.height - y
        }
        
        // Set horizontal alignment
        switch horizontalAlignment {
        case HorizontalAlignment.Left:
            break;
        case HorizontalAlignment.Center:
            x = (parentFrame.size.width / 2) - (w / 2);
            break;
        case HorizontalAlignment.Right:
            x = parentFrame.width - w - x;
            break;
        }
        
        // Set vertical alignment
        switch (verticalAlignment) {
        case VerticalAlignment.Top:
            break;
        case VerticalAlignment.Middle:
            y = (parentFrame.height / 2) - (h / 2);
            break;
        case VerticalAlignment.Bottom:
            y = parentFrame.height - y - h;
            break;
        }
        
        // Set padding
        let paddingTop = getDimension(self.paddingTop, parent: parentFrame.size.height)
        let paddingLeft = getDimension(self.paddingLeft, parent: parentFrame.size.width)
        let paddingRight = getDimension(self.paddingRight, parent: parentFrame.size.width)
        let paddingBottom = getDimension(self.paddingBottom, parent: parentFrame.size.height)

        // Top
        y += paddingTop
        h -= paddingTop
    
        // Left
        x += paddingLeft
        w -= paddingLeft
    
        // Right
        w -= paddingRight
    
        // Bottom
        h -= paddingBottom

        // Set offsets
        let offsetTop = getDimension(self.offsetTop, parent: parentFrame.size.height)
        let offsetLeft = getDimension(self.offsetLeft, parent: parentFrame.size.width)
        let offsetWidth = getDimension(self.offsetWidth, parent: parentFrame.size.width)
        let offsetHeight = getDimension(self.offsetHeight, parent: parentFrame.size.height)
        
        y += offsetTop
        x += offsetLeft
        w += offsetWidth
        h += offsetHeight
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    open func getDimension(_ dimension: String?, parent: CGFloat) -> CGFloat {
        var result: CGFloat = 0
        
        if dimension != nil {
            var cleaned = dimension!.replacingOccurrences(of: "+", with: "")
            
            if cleaned.hasSuffix("%") {
                cleaned = dimension!.replacingOccurrences(of: "%", with: "")
                let percent = toFloat(cleaned)
                result = (parent / CGFloat(100.0)) * percent
            } else {
                result = toFloat(cleaned)
            }
        }
        
        return result
    }
    
    open func getLastSiblingViewFrame(_ view: UIView) -> CGRect {
        var last: UIView?
        
        // Check parent view sublayers
        if let parent = parentView  {
            for sibling in parent.subviews {
                if sibling === view {
                    if last == nil {
                        return CGRect.zero
                    } else {
                        return last!.frame
                    }
                } else {
                    last = sibling
                }
            }
        }
        
        if let parent = parentView {
            if parent.subviews.count > 0 {
                return parent.subviews.last!.frame
            }
        }
                
        return CGRect.zero
    }
    
    open func getLastSiblingLayerFrame(_ layer: CALayer) -> CGRect {
        var last: CALayer?
        
        // Check parent view sublayers
        if let parent = parentView,let siblings = parent.layer.sublayers  {
            for sibling in siblings {
                if sibling === layer {
                    if last == nil {
                        return CGRect.zero
                    } else {
                        return last!.frame
                    }
                } else {
                    last = sibling
                }
            }
        }

        // Check parent layer sublayers
        if let parent = parentLayer, let siblings = parent.sublayers {
            for sibling in siblings {
                if sibling === layer {
                    if last == nil {
                        return CGRect.zero
                    } else {
                        return last!.frame
                    }
                } else {
                    last = sibling
                }
            }
        }
        
        // Doesn't exist: Check for parent view siblings
        if let parent = parentView,let siblings = parent.layer.sublayers  {
            if siblings.count > 0 {
                return siblings.last!.frame
            }
        }
        
        // Doesn't exist: Check for parent layer siblings
        if let parent = parentLayer, let siblings = parent.sublayers {
            if siblings.count > 0 {
                return siblings.last!.frame
            }
        }
        
        // Return empty rect
        return CGRect.zero
    }
    
    fileprivate func setAlignment(_ alignment: String) {
        let lower = alignment.lowercased()
        if lower.range(of: "left") != nil {
            horizontalAlignment = HorizontalAlignment.Left
        }
        if lower.range(of: "center") != nil {
            horizontalAlignment = HorizontalAlignment.Center
        }
        if lower.range(of: "right") != nil {
            horizontalAlignment = HorizontalAlignment.Right
        }
        if lower.range(of: "top") != nil {
            verticalAlignment = VerticalAlignment.Top
        }
        if lower.range(of: "middle") != nil {
            verticalAlignment = VerticalAlignment.Middle
        }
        if lower.range(of: "bottom") != nil {
            verticalAlignment = VerticalAlignment.Bottom
        }
    }
    
    fileprivate func toFloat(_ input: String?) -> CGFloat {
        if input != nil {
            if let n = NumberFormatter().number(from: input!) {
                return CGFloat(n)
            }
        }
        
        return CGFloat(0)
    }
}
