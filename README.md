# LocationKit

***An easy way to get the device's current location and geographical region monitoring on iOS(swift).***

LocationKit provide asynchronous block-based way to get the current location and region monitoring. It can manages multiple simultaneous location and region requests. Each request can specify its own setting like detect type(Once, UpdatingLocation, or SignificantLocationChanges), accuracy level, detect frequency, and distance filter.

## Features

* [x] Asynchronous block-based.
* [x] Get location. (Once, UpdatingLocation, or SignificantLocationChanges)
* [x] Geographic region monitoring.(enter/exit from regions)
* [x] Monitor more than 20 regions.
* [x] Manages multiple simultaneous location service.


## Requirements

- iOS 8.0+
- Xcode 8.0+ Swift 3

## Installation


### CocoaPods

Check out [Get Started](https://guides.cocoapods.org/using/getting-started.html) tab on [cocoapods.org](http://cocoapods.org/).

To use LocationKit in your project add the following 'Podfile' to your project

    pod 'JLocationKit', '~> 1.0.3'

Then run:

    pod install
    
Go ahead and import JLocationKit

### Source Code
Copy the LocationKit Directory to your project.
Go ahead and import LocationKit to your file.


## Example

Please check out the Example project included.


## <a name="documentation"></a>Documentation

* **[Prerequisites](#prerequisites)**
* **[Get Current User Location](#getLocation)**
	* [Once](#getLocation_once)
	* [Continuous](#getLocation_continuous)
	* [Significant Location Changes](#getLocation_significant)
	* [Location Response Information](#getLocation_response)  
* **[Geographical Region monitoring](#regionMonitoring)**
	* [Standard](#regionMonitoring_standard)
	* [Updating Location](#regionMonitoring_updating)
	* [Significant Location Changes](#regionMonitoring_significant)
	* [Region Response Information](#regionMonitoring_response)    
* **[Other](#other)**
	* [How to set the requests permission to use location services?](#setPermission)
	* [How to stop service?](#stopService)
	* [How to know the current authorization status has changed?](#authorizationStatus)
	* [How to create multiple simultaneous location service?](#multipleService)

## <a name="prerequisites"></a>Prerequisites

Before using LocationKit, you must configure your project to use location services. Apparently in iOS 8 SDK, requestAlwaysAuthorization (for background location) or requestWhenInUseAuthorization (location only when foreground) call on CLLocationManager is needed before starting location updates. Open ``Info.plist``, and add the following lines~
    
    <key>NSLocationWhenInUseUsageDescription</key>
     <string>LocationKit</string>
         <key>NSLocationAlwaysUsageDescription</key>
          <string>LocationKit</string>

The string value which you add will be shown when your app try to use location services at the first time.


## <a name="getLocation"></a>Get Current User Location

First, create a new LocationManager instance and set the requests permission to use location services.

***Here's an example:***

```swift
let location: LocationManager = LocationManager()
location.requestAccess = .requestAlwaysAuthorization //default is .requestAlwaysAuthorization 
```

[Documentation ↩︎](#documentation)

### <a name="getLocation_once"></a>Get Location (Once)

Get the device's current location(.Once style), then stop service automatically.

***Here's an example:***

```swift
location.getLocation(detectStyle: .Once, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, error: { (error) in
            //optional
        }
        )
```
[Documentation ↩︎](#documentation)

### <a name="getLocation_continuous"></a>Get Location (Continuous)

Get the device's current location(.UpdatingLocation style).
You must stop service manually.

***Here's an example:***

```swift
location.getLocation(detectStyle: .UpdatingLocation, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, error: { (error) in
            //optional
        }
        )
```

***You can set distanceFilter, locationAccuracy, and detectFrequency properties.***

* ***distanceFilter: Receive a new update when a new distance interval is travelled (default is 0 meter)***

```swift
distanceFilter: double value   //meter
```

* ***locationAccuracy: The accuracy of the location data (default is .Best)***

```swift
locationAccuracy: .Best //kCLLocationAccuracyBest
locationAccuracy: .BestForNavigation //kCLLocationAccuracyBestForNavigation
locationAccuracy: .HundredMeters //kCLLocationAccuracyHundredMeters
locationAccuracy: .Kilometer //kCLLocationAccuracyKilometer
locationAccuracy: .NearestTenMeters //kCLLocationAccuracyNearestTenMeters
locationAccuracy: .ThreeKilometers //kCLLocationAccuracyThreeKilometers
```
* ***detectFrequency: The frequency of the location update (default is 5 seconds)***

```swift
detectFrequency: Int value   //seconds
```

***You can get current location ever 5 seconds if you move more than 10 meter***

***Here's an example:***

```swift
location.getLocation(detectStyle: .UpdatingLocation, distanceFilter: 10, locationAccuracy: .Best, detectFrequency: 5, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, error: { (error) in
            //optional
        }
        )
```
[Documentation ↩︎](#documentation)

### <a name="getLocation_significant"></a> Get Location (Significant Location Changes)

If you use the .SignificantLocationChanges detectStyle to get location, this request will response new event only when it detects changes to the device’s associated cell towers, resulting in less frequent updates and significantly lower power usage, even when your app is terminated.(need requestAlwaysAuthorization requestAccess) 

***Here's an example:***

```swift
location.getLocation(detectStyle: .SignificantLocationChanges, distanceFilter: 0, completion: { (loc) in
                print(loc.currentLocation.coordinate.latitude.description)
                print(loc.currentLocation.coordinate.longitude.description)
            }, error: { (error) in
                //optional
            }
            )
```
***You don't need to set the locationAccuracy and detectFrequency properties.***

[Documentation ↩︎](#documentation)

### <a name="getLocation_response"></a> Location Response Information

```swift
public class JLocationResponse {
    public var currentLocation: CLLocation! //current location
    public var previousLocation: CLLocation! //the last time location
    public var distanceInterval: Double! //the interval distance from previous location to current location. 
}
```
[Documentation ↩︎](#documentation)

## <a name="regionMonitoring"></a>Geographical Region monitoring

You can easily to be notified when the user crosses a region based boundary.
LocationKit provide three region monitoring way.

First, you need to create region list which you want to monitior.

***Here's an example:***

```swift
//create region list
var locationList: [JLocation] = []
let item:JLocation = JLocation(latitude: 22.22222, longitude: 22.22222, radius: 500(meter), identifier: "test")
locationList.append(item)
```
[Documentation ↩︎](#documentation)

### <a name="regionMonitoring_standard"></a> Region monitoring (Standard)

It is a standard region monitoring way by didDetermineState function(.MonitoringRegion style).
In this way, you can monitor region even when your app is terminated(need requestAlwaysAuthorization requestAccess).
<mark>But, please note that there's a limit of 20 regions that can be monitored at the same time.</mark>

***Here's an example:***

```swift
location.regionNotify(notifyStyle: .MonitoringRegion, locations: locationList, completion: { (region) in
            print(region.regionState.description())
        }, error: { (error) in
        }
        )
```

***You don't need to set the locationAccuracy, distanceFilter and detectFrequency properties.***

[Documentation ↩︎](#documentation)

### <a name="regionMonitoring_updating"></a>Region monitoring (Updating Location)

In this way, you can monitor more than 20 regions(.UpdatingLocation style).
But, please note that can't monitor regions when your app is terminated.

***Here's an example:***

```swift
location.regionNotify(notifyStyle: .UpdatingLocation, distanceFilter: 0, locations: locationList, detectFrequency: 5, completion: { (region) in
            print(region.regionState.description())
        }, error: { (error) in
        }
        )
```

***You can set the locationAccuracy, distanceFilter and detectFrequency properties.***

[Documentation ↩︎](#documentation)

### <a name="regionMonitoring_significant"></a> Region monitoring (Significant Location Changes)

In this way, you can monitor more than 20 regions even when your app is terminated(need requestAlwaysAuthorization requestAccess).
But this request will response new event only when it detects changes to the device’s associated cell towers.

***Here's an example:***

```swift
location.regionNotify(notifyStyle: .SignificantLocationChanges, locations: locationList, completion: { (region) in
            print(region.regionState.description())
        }, error: { (error) in
        }
        )
```
***You don't need to set the locationAccuracy, distanceFilter and detectFrequency properties.***

[Documentation ↩︎](#documentation)

### <a name="regionMonitoring_response"></a> Region Response Information
```swift
public class JRegion:CLCircularRegion {
    public var regionRadius: Double! //the radius of region
    public var regionIdentifier: String! //the region identifier
    public var regionState: RegionState! // region state(inside/outside)
    public var previousIntervalSec: Int! = 0 //the time(seconds) from previous location to current location
    public var previousDate: Date! //the previous location date when you enter
    public var firstNotify: Bool = false //at first when you enter region, it will be true
}
```

[Documentation ↩︎](#documentation)

## <a name="other"></a>Other

### <a name="setPermission"></a> How to set the requests permission to use location services?

You can set the requests permission by LocationManager instance.

***Here's an example:***

```swift
let location: LocationManager = LocationManager()
location.requestAccess = .requestAlwaysAuthorization //default is .requestAlwaysAuthorization 
```
`.requestWhenInUseAuthorization //when in use`

`.requestAlwaysAuthorization     //always`

[Documentation ↩︎](#documentation)


### <a name="stopService"></a> How to stop service?

You can use `.stopAll` to stop all location service.

***Here's an example:***

```swift
location.stopAll()
```

Or, you can create an identification service


```swift
location.getLocation(detectStyle: .UpdatingLocation, distanceFilter: 0, detectFrequency: 15, identification: "test", completion: { (loc) in
                print(loc.currentLocation.coordinate.latitude.description)
                print(loc.currentLocation.coordinate.longitude.description)
        }
        )
```

Now, you can stop this service by identification name.

```swift
location.stop(identification: "test")
```

[Documentation ↩︎](#documentation)

### <a name="authorizationStatus"></a> How to know the current authorization status has changed? 

You can get the change event by authorizationChange block

***Here's an example:***

```swift
location.getLocation(detectStyle: .UpdatingLocation, distanceFilter: 0, locationAccuracy: .NearestTenMeters, detectFrequency: 10, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, authorizationChange: { (status) in
            //optional (CLAuthorizationStatus)
        }
        )
```



[Documentation ↩︎](#documentation)

### <a name="multipleService"></a> How to create multiple simultaneous location service? 

When you create LocationManager instance, the default number of managed location service is ten. 
You can easily get multiple simultaneous location service response.

***Here's an example:***

```swift
let location: LocationManager = LocationManager()
location.requestAccess = .requestAlwaysAuthorization

location.getLocation(detectStyle: .UpdatingLocation, distanceFilter: 0, locationAccuracy: .NearestTenMeters, detectFrequency: 10, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, authorizationChange: { (status) in
            //optional (CLAuthorizationStatus)
        }
        )
                
location.getLocation(detectStyle: .SignificantLocationChanges, distanceFilter: 0, locationAccuracy: .NearestTenMeters, detectFrequency: 10, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, authorizationChange: { (status) in
            //optional (CLAuthorizationStatus)
        }
        )
        
location.regionNotify(notifyStyle: .MonitoringRegion, distanceFilter: 0, locations: locationList, completion: { (region) in
            print(region.regionState.description())
        }, error: { (error) in
        }
        )
```
If you want LocationKit to manage more than ten simultaneous location service, you can set the detect instance number.

***Here's an example:***

```swift
let location: LocationManager = LocationManager(detectInstanceNumber: 20)
```

[Documentation ↩︎](#documentation)

## License

LocationKit is available under the MIT License.

Copyright © 2016 Joe.

