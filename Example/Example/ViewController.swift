//
//  ViewController.swift
//  Example
//
//  Created by JoeJoe on 2016/12/29.
//  Copyright © 2016年 Joe. All rights reserved.
//

import UIKit
import LocationKit

class ViewController: UIViewController {
    
    //create LocationManager instance
    let location: LocationManager = LocationManager()
    //let location: LocationManager = LocationManager(detectInstanceNumber: 20)
    var locationList: [JLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set authorization
        location.requestAccess = .requestWhenInUseAuthorization
        
        //get current location(once)
        location.getLocation(detectStyle: .Once, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, authorizationChange: { (status) in
            //optional
        }
        )
        
        //get current location ever 5 seconds if you move more than 0 meter
        location.getLocation(detectStyle: .UpdatingLocation, distanceFilter: 0, locationAccuracy: .NearestTenMeters, detectFrequency: 5, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, error: { (error) in
            //optional
        }, authorizationChange: { (status) in
            //optional
        }
        )
        
        //get current location by SignificantLocationChanges
        location.getLocation(detectStyle: .SignificantLocationChanges, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, error: { (error) in
            //optional
        }, authorizationChange: { (status) in
            //optional
        }
        )
        
        //get current location by SignificantLocationChanges
        location.getLocation(detectStyle: .SignificantLocationChanges, completion: { (loc) in
            print(loc.currentLocation.coordinate.latitude.description)
            print(loc.currentLocation.coordinate.longitude.description)
        }, error: { (error) in
            //optional
        }, authorizationChange: { (status) in
            //optional
        }
        )
        
        //create region list
        let item1: JLocation = JLocation(latitude: -26.2041028, longitude: 28.0473051, radius: 5000, identifier: "Johannesburg")
        let item2: JLocation = JLocation(latitude: 51.50998, longitude: -0.1337, radius: 5000, identifier: "London")
        locationList.append(item1)
        locationList.append(item2)
        
        //region monitoring (Standard)
        location.regionNotify(notifyStyle: .MonitoringRegion, locations: locationList, completion: { (region) in
            print(region.regionState.description())
        }, error: { (error) in
            //optional
        }
        )
        
        //region monitoring (Updating Location)
        location.regionNotify(notifyStyle: .UpdatingLocation, distanceFilter: 0, locations: locationList, detectFrequency: 5, completion: { (region) in
            print(region.regionState.description())
        }, error: { (error) in
            //optional
        }
        )
        
        //region monitoring (Significant Location Changes)
        location.regionNotify(notifyStyle: .SignificantLocationChanges, locations: locationList, completion: { (region) in
            print(region.regionState.description())
        }
        )
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func StopButton(_ sender: Any) {
        //stop location service
        location.stopAll()
    }
}
