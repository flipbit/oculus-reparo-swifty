## Oculus Reparo - A Swifty UIKit Layout Manager

Oculus Reparo allows you write simple view layouts in plain text, and use them to build your iOS application views.

```sass
/* Let's define some variables */
@set red:   ff3b30;
@set amber: ff9500;
@set green: 4cd964;
@set grey:  8e8e93;

/* Add a UIButton */
button {
    /* Set it's position */
    position {
        top: 20             @if portrait;       /* Let's move the button depending */
        top: 0              @if landscape;      /* on the screen's orientation */
        left: 0;
        width: 100;
        height: 44;
    }

    font-size: 17;                              /* Font parameters */
    font-weight: regular;
    text-alignment: left;

    title: Back;                                /* Title */
    title-color: @grey;
    
    on-touch: onBack;                           /* Objective C Selector */

    image-bundle: BackwardDisclosure22x22;      /* Image parameters */
    tint-color: @grey;
    image-edge-insets: 0 7.5 0 7.5;
}

/* Add a UIView */
view {
    position @if portrait {                     /* Position if portrait */
        align: center middle;
        height: 300;
        width: 80;
    }

    position @if landscape {                    /* Position if landscape */
        align: center middle;
        height: 80;
        width: 300;
    }

    /* Define a mixin */
    @define: light {
        /* Add a CALayer */
        layer {
            position {
                top: @position      @if portrait;
                left: 0             @if portrait;
                top: 0              @if landscape;
                left: @position     @if landscape;
                width: 80;
                height: 80;
            }

            background-color: @color;
            corner-radius: 40;
        }
    }
    
    /* Include red light... */
    @light {
        position: 0;
        color: @red;
    }

    /* Include amber light */
    @light {
        position: +20;
        color: @amber;
    }

    /* Include green light */
    @light {
        position: 200;
        color: @green;
    }
}
```

Produces the following views in portrait / landscape:
<p align="center">
  <img src="https://raw.githubusercontent.com/flipbit/oculus-reparo-swifty/master/Assets/Screenshots/TrafficLights.png" />
</p>
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
