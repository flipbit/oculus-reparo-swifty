## Oculus Reparo - A Swifty UIKit Layout Manager

Oculus Reparo allows you write simple view layouts in plain text, and use them to build your iOS application views.

```css
view {
    position {
        align: center middle;
        height: 100;
        width: 100;
    }

    background-color: 0076ff;
    corner-radius: 10;
}
```

Produces the following view:

![Oculus Reparo Basic Layout Screenshot](https://raw.githubusercontent.com/flipbit/oculus-reparo-swifty/master/Assets/Screenshots/basic.png)

Oculus Reparo supports:

* UIViews and CALayers
* Nesting elements
* Model binding
* Event binding
* Device, screen resolution and orientation detection
* Variables
* Include files
* Functions
* Extension hooks to support custom UIView and CALayer types, layout loading, image loading and functions.

## Usage

Using OculusReparo is simple, create an instance of the class, supply a view name and call the apply() function to build your view.

```swift
import OculusReparo

class OculusReparoController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = Layout(filename: "hello-world.layout", controller: self)
        
        try! layout!.apply()
    }
}
```

## Installation

OculusReparo is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "OculusReparo"
```

## Supported UIView elements:

* UIView
* UILabel
* UIButton
* UISlider
* UIScrollView

## Supported CALayer elements:

* CALayer
