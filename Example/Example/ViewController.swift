//
//  ViewController.swift
//  Example
//
//  Created by JoeJoe on 2016/12/29.
//  Copyright © 2016年 Joe. All rights reserved.
//

import UIKit
import LocationKit
import CoreLocation

class ViewController: UIViewController {
    
    let location: LocationManager = LocationManager(detectInstanceNumber: 5)
    let location1: LocationManager = LocationManager()
    var location_list: [JLocation] = []
    var location_list2: [JLocation] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        UIApplication.shared.beginBackgroundTask(expirationHandler: {})
        
//        for i in 1...5000 {
//            let item3:JLocation = JLocation(latitude: 27.077637 + 1*(Double)(i), longitude: 121.577047, radius: 50, identifier: "joe"+i.description)
//            location_list.append(item3)
//        }
        
        let item:JLocation = JLocation(latitude: -26.2041028, longitude: 28.0473051, radius: 500, identifier: "test")
        let item1:JLocation = JLocation(latitude: 51.50998, longitude: -0.1337, radius: 1, identifier: "testxxx")
        
        let item2:JLocation = JLocation(latitude: 25.077337, longitude: 121.577047, radius: 5000, identifier: "joe123")
        location_list.append(item2)
        location_list2.append(item1)
        //location_list.append(item1)
        

        
//        location.getLocation(detectStyle: .standard, requestAccess: .requestAlwaysAuthorization, allowsBackgroundLocationUpdates: false, completion: { (loc) in
//            if(loc.0){
//                print(loc.1.coordinate.latitude.description)
//                print(loc.1.coordinate.longitude.description)
//                //self.beaconNotificationMessage(message: loc.1.coordinate.latitude.description)
//            }
//        }
//        )
//
//        location.getLocation(detectStyle: .standard, requestAccess: .requestAlwaysAuthorization, completion: { (loc) in
//            if(loc.0){
//                print(loc.1.coordinate.latitude.description)
//                print(loc.1.coordinate.longitude.description)
//            }
//        }
//        )
        
//        location.regionNotify(notifyStyle: .MonitoringRegion, requestAccess: .requestAlwaysAuthorization, distanceFilter: 10, locations: location_list, detectFrequency: 1, identification: "test", completion: { (region) in
//            if(region.0) {
//                print(region.1.previousEnterIntervalSec)
//                print(region.1.firstNotify)
//                if region.1.previousEnterIntervalSec > 10 || region.1.firstNotify {
//                    if region.1.regionState == .outside {
//                        //self.beaconNotificationMessage(message: region.1.regionState.description())
//                    } 
//                }
//            }},
//            error: { (error) in
//                if error.0 {
//                    
//                }
//        }
//        )
//
        location.regionNotify(notifyStyle: .SignificantLocationChanges, requestAccess: .requestAlwaysAuthorization, distanceFilter: 0, locations: location_list, detectFrequency: 1, identification: "test2", completion: { (region) in
            //if(region.0) {
                //print(region.1.previousEnterIntervalSec)
                //print(region.1.firstNotify)
                //self.beaconNotificationMessage(message: region.regionState.description())
                if region.previousEnterIntervalSec > 10 || region.firstNotify {
                    if region.regionState == .inside {
                        self.beaconNotificationMessage(message: region.regionState.description())
                    }
                }
            //}
        },
                              error: { (error) in

        }
        )
        
//        location.regionNotify(notifyStyle: .significant ,requestAccess: .requestAlwaysAuthorization, locations: location_list, completion: { (region) in
//            if(region.0) {
//                if region.1.previousNotifySec > 10 || region.1.firstNotify {
//                    if region.1.regionState == .inside {
//                        self.beaconNotificationMessage(message: region.1.regionState.description())
//                    }
//                }
//            }
//        }
//        )
//        
        
        
//        location.regionNotify(notifyStyle: .standard ,requestAccess: .requestAlwaysAuthorization, locations: location_list2, completion: { (loc) in
//            if(loc.0) {
// 
// 
//            }
//        }
//        )
//
//        location.regionNotify(notifyStyle: .region ,requestAccess: .requestAlwaysAuthorization, locations: location_list, completion: { (loc) in
//            if(loc.0){
//                //                for item in loc.1{
//                //                    if item.regionState == .inside {
//                //
//                //                    }
//                //                }
//            }
//        }
//        )
        
        location.getLocation(detectStyle: .SignificantLocationChanges, distanceFilter: 0, detectFrequency: 5, completion: { (loc) in
            
                print(loc.currentLocation.coordinate.latitude.description)
                print(loc.currentLocation.coordinate.longitude.description)
                self.beaconNotificationMessage(message: loc.currentLocation.coordinate.latitude.description)
            
        }
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    @IBAction func ActionButton(_ sender: Any) {
        //let locations: LocationManager = LocationManager(detectInstanceNumber: 5)
        location.getLocation(detectStyle: .UpdatingLocation, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, error: { (error) in
            //optional
        }
        )

        
//        location.getLocation(detectStyle: .UpdatingLocation, distanceFilter: 0, detectFrequency: 5, completion: { (loc) in
//            if(loc.0){
//                print(loc.1.currentLocation.coordinate.latitude.description)
//                print(loc.1.currentLocation.coordinate.longitude.description)
//                self.beaconNotificationMessage(message: loc.1.currentLocation.coordinate.latitude.description)
//                guard let p = loc.1.distanceInterval?.description else { return }
//                print(p)
////                CLGeocoder().reverseGeocodeLocation(loc.1, completionHandler: {(placemarks, error) -> Void in
////
////                    if error != nil {
////                        print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
////                        return
////                    }
////                    
////                    if (placemarks?.count)! > 0 {
////                        print(placemarks?[0].addressDictionary)
////                    }
////                    else {
////                        print("Problem with the data received from geocoder")
////                    }
////                })
//            }
//        }
//        )
        
    }
    @IBAction func StopButton(_ sender: Any) {
        location.stopAll()//stop(identification: "test")
    }
    
    func beaconNotificationMessage(message: String!) {
        let notification:UILocalNotification = UILocalNotification()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertBody = message
        notification.alertAction = "ok"
        UIApplication.shared.scheduleLocalNotification(notification)
    }
}
