import Foundation
import UIKit

/// Applies AutoLayout constraints to Layout
public class LayoutConstrainer {
    public init() {        
    }
    
    public func add(layout: Layout) throws {
        for key in layout.viewFragments.keys {
            if let fragment = layout.viewFragments[key] {
                try add(layout, fragment: fragment)
            }
        }
    }

    func add(layout: Layout, fragment: LayoutViewFragment) throws {
        let config = fragment.configuration, view = fragment.view
        
        // Anchor types
        let tlbr = [AnchorType.Top, AnchorType.Left, AnchorType.Bottom, AnchorType.Right, AnchorType.CenterX, AnchorType.CenterY]
        
        // Check for anchors
        for anchor in tlbr {
            if let section = config.getSection(anchor.rawValue) {
                let anchorToViewId = section.getString("to", ifMissing: "@parent") ?? "@parent"
                let constant = section.getCGFloat("constant", ifMissing: 0)
                let to = try Convert.getViewIdAndAnchor(anchorToViewId, defaultIdView: "@parent", defaultAnchor: anchor)
                var anchorToView: UIView?
                
                switch to.viewId.lowercaseString {
                case "@parent":
                    anchorToView = view.superview
                    
                case "@next":
                    anchorToView = view.findNextSibling()
                    
                case "@last":
                    anchorToView = view.findPreviousSibling()
                    
                default:
                    anchorToView = layout.findView(to.viewId)
                }
                
                if anchorToView == nil {
                    let info = LayoutErrorInfo(message: "Unable to find view to anchor to: \(to.viewId)", filename: section.filename, lineNumber: section.lineNumber)
                    
                    throw LayoutError.ConfigurationError(info)
                }
                
                addConstraint(on: view, to: anchorToView!, onAnchor: anchor, toAnchor: to.anchor, constant: constant)
            }
                
            else if config.hasValue(anchor.rawValue) {
                let constant = config.getCGFloat(anchor.rawValue, ifMissing: 0)
                let parent = view.superview!
                
                addConstraint(on: view, to: parent, onAnchor: anchor, toAnchor: anchor, constant: constant)
            }
        }
        
        // Snap-to
        snapLeft(view, config: config)
        snapRight(view, config: config)
        snapTop(view, config: config)
        
        // parent snap-to
        parentSnapTop(view, config: config)
        parentSnapLeft(view, config: config)
        parentSnapRight(view, config: config)
        parentSnapBottom(view, config: config)
    }

    private func parentSnapBottom(view: UIView, config: Section) {
        parentSnap(view, config: config, name: "snap-parent-bottom", anchor: .Bottom, invert: true)
    }
    
    private func parentSnapTop(view: UIView, config: Section) {
        parentSnap(view, config: config, name: "snap-parent-top", anchor: .Top, invert: false)
    }
    
    private func parentSnapLeft(view: UIView, config: Section) {
        parentSnap(view, config: config, name: "snap-parent-left", anchor: .Left, invert: false)
    }

    private func parentSnapRight(view: UIView, config: Section) {
        parentSnap(view, config: config, name: "snap-parent-right", anchor: .Right, invert: true)
    }
    
    private func parentSnap(view: UIView, config: Section, name: String, anchor: AnchorType, invert: Bool) {
        if config.hasValue(name) {
            if let to = view.superview {
                var constant = config.getCGFloat(name, ifMissing: 0)
                
                if invert {
                   constant = constant * -1
                }
                
                addConstraint(on: view, to: to, onAnchor: anchor, toAnchor: anchor, constant: constant)
            }
        }
    }
    
    
    private func snapLeft(view: UIView, config: Section) {
        if config.hasValue("snap-left") {
            let to = view.findPreviousSiblingOrSuperview()!
            let toAnchor = to === view.superview ? AnchorType.Left : AnchorType.Right
            let constant = config.getCGFloat("snap-left", ifMissing: 0)
            
            addConstraint(on: view, to: to, onAnchor: .Left, toAnchor: toAnchor, constant: constant)
        }
    }
    
    private func snapRight(view: UIView, config: Section) {
        if config.hasValue("snap-right") {
            let to = view.findNextSiblingOrSuperview()!
            let toAnchor = to === view.superview ? AnchorType.Right : AnchorType.Left
            let constant = config.getCGFloat("snap-right", ifMissing: 0) * -1
            
            addConstraint(on: view, to: to, onAnchor: .Right, toAnchor: toAnchor, constant: constant)
        }
    }

    private func snapTop(view: UIView, config: Section) {
        if config.hasValue("snap-top") {
            let to = view.findPreviousSiblingOrSuperview()!
            let toAnchor = to === view.superview ? AnchorType.Top : AnchorType.Bottom
            let constant = config.getCGFloat("snap-top", ifMissing: 0)
            
            addConstraint(on: view, to: to, onAnchor: .Top, toAnchor: toAnchor, constant: constant)
        }
    }
    
    func addConstraint(on on: UIView, to: UIView, onAnchor: AnchorType, toAnchor: AnchorType, constant: CGFloat) {
        let onAnchor = getAnchor(on, anchor: onAnchor)
        let toAnchor = getAnchor(to, anchor: toAnchor)
        
        if on.translatesAutoresizingMaskIntoConstraints {
            on.translatesAutoresizingMaskIntoConstraints = false
            
            if on.frame != CGRectZero {
                if on.frame.height != 0 {
                    on.heightAnchor.constraintEqualToConstant(on.frame.height).active = true
                }
                if on.frame.width != 0 {
                    on.widthAnchor.constraintEqualToConstant(on.frame.width).active = true
                }
                on.frame = CGRectZero
            }
        }
        
        onAnchor.constraintEqualToAnchor(toAnchor, constant: constant).active = true
    }
    
    func getAnchor(view: UIView, anchor: AnchorType) -> NSLayoutAnchor {
        switch (anchor) {
        case .Bottom:
            return view.bottomAnchor
        case .Left:
            return view.leftAnchor
        case .Right:
            return view.rightAnchor
        case .Top:
            return view.topAnchor
        case .CenterY:
            return view.centerYAnchor
        case .CenterX:
            return view.centerXAnchor
        }
        
    }
}
