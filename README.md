LocationKit
=======
An easy way to get the device's current location and region monitoring on iOS.

LocationKit provide asynchronous block-based way to get the current location and region monitoring. It can manages multiple simultaneous location and region requests. Each onetime request can specify its own setting like detect type(Once, UpdatingLocation, or SignificantLocationChanges), accuracy level, detect frequency, and distance filter.


Features
----------
- [x] Get location. (Once, UpdatingLocation, or SignificantLocationChanges)
- [x] Geographic region monitoring.(enter/exit from regions)
- [x] Monitor more than 20 regions.
- [x] Manages multiple simultaneous location and region requests.


Requirements
----------

- iOS 8.0+
- Xcode 8.0+ Swift 3

Installation
----------

#### CocoaPods

soon~

#### Source Code
Copy the LocationKit Directory to your project.
Go ahead and import LocationKit to your file.


Pre-requisites
----------

Before using LocationKit you must configure your project to use location services. 

Apparently in iOS 8 SDK, requestAlwaysAuthorization (for background location) or requestWhenInUseAuthorization (location only when foreground) call on CLLocationManager is needed before starting location updates.

Open Info.plist, and add the following lines~

    <key>NSLocationWhenInUseUsageDescription</key>
     <string>LocationKit</string>
         <key>NSLocationAlwaysUsageDescription</key>
          <string>LocationKit</string>
Your app will shown the string value when it try to use at the first time

The string value which you add will be shown when your app try to use location services at the first time.

If you need background monitoring you should specify ```NSLocationAlwaysUsageDescription``` or specify the correct value in ```UIBackgroundModes``` key


Example
----------

####Please check out the Example project included.


Usage
----------

* Get Location(once): 

Get the device's current location(.Once style), then stop request automatically.

This is a example:
```swift
let location: LocationManager = LocationManager()
location.getLocation(detectStyle: .Once, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, error: { (error) in
            //optional
        }
        )
```

* Get Location(continous):

Get the device's current location(.UpdatingLocation style).
You must stop it manually.

This is a example:
```swift
let location: LocationManager = LocationManager()
location.getLocation(detectStyle: .UpdatingLocation, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, error: { (error) in
            //optional
        }
        )
```

You can set the accuracy, distanceFilter, and detect frequcency.

For example:
```swift
let location: LocationManager = LocationManager()
location.getLocation(detectStyle: .UpdatingLocation, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, error: { (error) in
            //optional
        }
        )
```


Customization
----------
You can configure NotificationBanner properties.

* NotificationBanner style(Success, Info, Warning, Error, and Custom banner type)*
```swift
bannerStyle: .sucessMessage   //Success style
bannerStyle: .infoMessage     //Info style
bannerStyle: .warningMessage  //Warning style
bannerStyle: .errorMessage    //Error style
bannerStyle: .customView      //Custom style
```

* NotificationBanner location on the view
```swift
bannerLocation: .Top     //Top
bannerLocation: .Bottom  //Bottom
```

* NotificationBanner title message
```swift
messageTitle: String     //title message
```

* NotificationBanner content message
```swift
messageContent: String     //content message
```

* NotificationBanner title string font
```swift
messageTitleFont: CGFloat     //title string font, default is 25
```


* NotificationBanner content string font
```swift
messageContentFont: CGFloat     //content string font, default is 15
```

* NotificationBanner Height
```swift
bannerHeight: Int     //banner height, default is 80
```

* NotificationBanner hold time(second)
```swift
bannerHoldTime: Int     //banner hold time, default is 5 sec
```

* If your bannerStyle is .customView(Custom style), you can configure bannerBackgroundColor and bannerImage properties
```swift
bannerBackgroundColor: UIColor     //banner background color
bannerImage: UIImage               //banner icon image
```

License
----------

NotificationBanner is available under the MIT License.

Copyright © 2016 Joe.

