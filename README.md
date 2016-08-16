## Oculus Reparo - A Swifty UIKit Layout Manager

Oculus Reparo allows you write simple view layouts in plain text, and use them to build your iOS application views.

```sass
/* Let's define some variables */
@set red:   #ff3b30;
@set amber: #ff9500;
@set green: #4cd964;
@set grey:  #8e8e93;

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

    font-size:              17;                 /* Font parameters */
    font-weight:            regular;
    text-alignment:         left;

    title: Back;                                /* Title */
    title-color:            @grey;
    
    on-touch:               onBack;             /* Objective C Selector */

    tint-color:             @grey;              /* Image parameters */
    image-edge-insets:      0 7.5 0 7.5;
    image-bundle:           BackwardDisclosure22x22;
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
    @define: traffic-light {
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

            id: @id;
            background-color: @color;
            corner-radius: 40;
            opacity: 0.5;
        }
    }
    
    /* Include red light... */
    @traffic-light {
        id: red;
        position: 0;
        color: @red;
    }

    /* Include amber light */
    @traffic-light {
        id: amber;
        position: +20;
        color: @amber;
    }

    /* Include green light */
    @traffic-light {
        id: green;
        position: +20;
        color: @green;
    }
}
```

A LayoutViewController is supplied out of the box to help you render your view, however you can manage the view lifecycle yourself if you want full control over the screen size and orientation changes.

```swift
class TrafficLightsController : LayoutViewController {
    var red: CALayer?
    var amber: CALayer?
    var green: CALayer?
    
    override func viewWillLayout() {
        layout.filename  = "TrafficLights.layout"
        layout.model = self
    }
    
    override func viewDidLayout() {
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
    }
    
    func onBack() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func onTimer(timer: NSTimer) {
        if red?.opacity == 1 {
            red?.opacity = 0.5
            amber?.opacity = 1
        }

        else if amber?.opacity == 1 {
            amber?.opacity = 0.5
            green?.opacity = 1
        }

        else {
            green?.opacity = 0.5
            red?.opacity = 1
        }
    }
}
```

<p align="center">
  <img src="https://raw.githubusercontent.com/flipbit/oculus-reparo-swifty/master/Assets/Screenshots/traffic-lights.gif" />
</p>

## Supported Featues

* UIViews and CALayers
* Nesting elements
* Model binding
* Event binding
* Screen resolution and orientation detection
* Auto Layout
* Variables
* Include files
* Functions
* Extension hooks

## Installation

OculusReparo is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "OculusReparo"
```

