//
//  LocationDetection.swift
//  LocationKit
//
//  Created by JoeJoe on 2017/1/6.
//  Copyright © 2017年 Joe. All rights reserved.
//

import Foundation
import CoreLocation

internal class LocationDetection: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    var selfManager: LocationManager!
    var managerId: Int!
    var regionQueue: DispatchQueue!
    var locationQueue: DispatchQueue!

    public override init () {
        //print("LocationKit has been initialised")
    }

    internal func startLocationDetection(manger: LocationManager, detectionItem: DetectionInfo) {
        locationManager = CLLocationManager()
        managerId = detectionItem.id
        locationQueue = DispatchQueue(label: "locationQueue" + managerId.description)
        regionQueue = DispatchQueue(label: "regionQueue" + managerId.description)
        
        switch detectionItem.access as RequestAccess {
        case RequestAccess.requestAlwaysAuthorization:
            locationManager.requestAlwaysAuthorization()
            break
        case RequestAccess.requestWhenInUseAuthorization:
            locationManager.requestWhenInUseAuthorization()
            break
        }
        
        switch detectionItem.accuracy as LocationAccuracy {
        case LocationAccuracy.Best:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            break
        case LocationAccuracy.BestForNavigation:
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            break
        case LocationAccuracy.HundredMeters:
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            break
        case LocationAccuracy.Kilometer:
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            break
        case LocationAccuracy.NearestTenMeters:
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            break
        case LocationAccuracy.ThreeKilometers:
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            break
        }
        
        if #available(iOS 9.0, *) {
            let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"]
            if backgroundModes != nil {
                if (backgroundModes as! Array).contains("location") {
                    locationManager.allowsBackgroundLocationUpdates = true
                } else {
                    print("Please turn on BackgroundModes and tick the location update checkbox")
                }
            } 
        }
        
        switch detectionItem.style {
        case "NotifyStyle":
            setRegion(detectionItem: detectionItem)
            switch detectionItem.notifyStyle as NotifyStyle {
            case NotifyStyle.MonitoringRegion:
                for item in locationManager.monitoredRegions {
                    locationManager.stopMonitoring(for: item)
                }
                for item in detectionItem.regionList {
                    locationManager.startMonitoring(for: item)
                }
                break
            case NotifyStyle.UpdatingLocation:
                locationManager.startUpdatingLocation()
                break
            case NotifyStyle.SignificantLocationChanges:
                locationManager.startMonitoringSignificantLocationChanges()
                break
            }
            break
        case "DetectStyle":
            switch detectionItem.detectStyle as DetectStyle {
            case DetectStyle.UpdatingLocation, DetectStyle.Once:
                if detectionItem.detectStyle == .Once {
                    detectionItem.frequency = 0
                    detectionItem.distanceFilter = 0
                }
                locationManager.startUpdatingLocation()
                break
            case DetectStyle.SignificantLocationChanges:
                locationManager.startMonitoringSignificantLocationChanges()
                break
            }
            break
        default:
            break
        }
        locationManager.delegate = self
        selfManager = manger
    }
    
    private func setRegion(detectionItem: DetectionInfo) {
        for item in detectionItem.locationList {
            let center = CLLocationCoordinate2DMake(item.coordinate.latitude, item.coordinate.longitude)
            var radius = item.locationRadius!
            if radius > locationManager.maximumRegionMonitoringDistance {
                radius = locationManager.maximumRegionMonitoringDistance
            }
            let regionItem = JRegion(centerPoint: center, radius: radius, identifier: item.locationIdentifier)
            regionItem.notifyOnEntry = true
            regionItem.notifyOnExit = true
            detectionItem.regionList.append(regionItem)
        }
    }
    
    private func getPrevious(item: DetectionInfo, style: RegionState) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let nowDate = dateFormatter.date(from: dateFormatter.string(from: NSDate() as Date))
        let unit = Set<Calendar.Component>([.second])
        let cal = NSCalendar.current
        switch style {
        case .inside:
            if item.insideDatetime == nil {
                item.insideDatetime = nowDate
                return 0
            } else {
                let components = cal.dateComponents(unit, from: item.insideDatetime, to: nowDate!)
                item.insideDatetime = nowDate
                guard let sec: Int = components.second! - 1 else { return -1 }
                return sec
            }
        case .outside:
            if item.insideDatetime == nil {
                item.insideDatetime = nowDate
                return 0
            } else {
                let components = cal.dateComponents(unit, from: item.insideDatetime, to: nowDate!)
                item.outsideDatetime = nowDate
                guard let sec: Int = components.second! - 1 else { return -1 }
                return sec
            }
        }
    }
    
    private func checkPrevious(item: DetectionInfo) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let nowDate = dateFormatter.date(from: dateFormatter.string(from: NSDate() as Date))
        let unit = Set<Calendar.Component>([.second])
        let cal = NSCalendar.current
        
        if item.previousLocationDatetime == nil {
            item.previousLocationDatetime = nowDate
            return true
        } else {
            let components = cal.dateComponents(unit, from: item.previousLocationDatetime, to: nowDate!)
            if components.second! - 1 >= item.frequency {
                item.previousLocationDatetime = nowDate
                return true
            } else {
                return false
            }
        }
    }
    
    private func checkStates() -> UIApplicationState {
        return UIApplication.shared.applicationState
    }
    
    internal func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        regionQueue.async(execute: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            guard let detectionItem: DetectionInfo = strongSelf.selfManager.regionDetectionList.filter({$0.id == strongSelf.managerId}).first else { return }
            if detectionItem.style == "NotifyStyle" {
                if !detectionItem.regionList.contains(where: {$0.identifier == region.identifier}) {
                    if detectionItem.notifyStyle == .MonitoringRegion {
                    strongSelf.locationManager.stopMonitoring(for: region)
                    }
                } else {
                    let regionItem: JRegion = detectionItem.regionList.filter({$0.regionIdentifier == region.identifier}).first!
                    DispatchQueue.main.async(execute: { () -> Void in
                        guard let strongSelf = self else { return }
                        switch state {
                        case .inside:
                            regionItem.regionState = .inside
                            regionItem.previousDate = detectionItem.insideDatetime
                            regionItem.previousIntervalSec = strongSelf.getPrevious(item: detectionItem, style: .inside)
                            if regionItem.previousIntervalSec == 0 {
                                regionItem.firstNotify = true
                            } else {
                                regionItem.firstNotify = false
                            }
                            detectionItem.regionCompletion(regionItem)
                            break
                        case .outside:
                            regionItem.regionState = .outside
                            regionItem.previousDate = detectionItem.insideDatetime
                            regionItem.previousIntervalSec = strongSelf.getPrevious(item: detectionItem, style: .outside)
                            detectionItem.regionCompletion(regionItem)
                            break
                        default:
                            break
                        }
                    })
                }
            }
        })
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationQueue.async(execute: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            if locations.count > 0 {
                guard let detectionItem: DetectionInfo = strongSelf.selfManager.regionDetectionList.filter({$0.id == strongSelf.managerId && $0.state == "Start"}).first else { return }
                if detectionItem.style == "NotifyStyle" {
                    for item in detectionItem.locationList {
                        if detectionItem.regionList.count > 0 {
                            let regionItem: JRegion = detectionItem.regionList.filter({$0.regionIdentifier == item.locationIdentifier}).first!
                            DispatchQueue.main.async(execute: { () -> Void in
                                guard let strongSelf = self else { return }
                                
                                if detectionItem.previousLocation == nil {
                                   detectionItem.previousLocation = locations[0]
                                }
                                guard detectionItem.previousLocation.distance(from: locations[0]) >= detectionItem.distanceFilter else { return }
                                detectionItem.previousLocation = locations[0]
                                let distance = item.distance(from: locations[0])
                                if distance <= item.locationRadius {
                                    if !regionItem.insideActive {
                                        regionItem.regionState = .inside
                                        regionItem.insideActive = true
                                        regionItem.previousDate = detectionItem.insideDatetime
                                        regionItem.previousIntervalSec = strongSelf.getPrevious(item: detectionItem, style: .inside)
                                        if regionItem.previousIntervalSec == 0 {
                                            regionItem.firstNotify = true
                                        } else {
                                            regionItem.firstNotify = false
                                        }
                                        detectionItem.regionCompletion(regionItem)
                                    }
                                    
                                } else {
                                    if  regionItem.insideActive {
                                        regionItem.regionState = .outside
                                        regionItem.insideActive = false
                                        regionItem.previousDate = detectionItem.outsideDatetime
                                        regionItem.previousIntervalSec = strongSelf.getPrevious(item: detectionItem, style: .outside)
                                        detectionItem.regionCompletion(regionItem)
                                    }
                                }
                            })
                        }
                    }
                    if detectionItem.notifyStyle == .UpdatingLocation {
                        if detectionItem.access == .requestAlwaysAuthorization || UIApplication.shared.applicationState == .active {
                            detectionItem.lcoationDetection.locationManager.stopUpdatingLocation()
                            detectionItem.state = "Stop"
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(detectionItem.frequency)) {
                            guard let manager =  detectionItem.lcoationDetection.locationManager else { return }
                            manager.startUpdatingLocation()
                            detectionItem.state = "Start"
                            }
                        }
                    }
                } else {
                    if detectionItem.lcoationDetection.locationManager != nil {
                        let response: JLocationResponse = JLocationResponse()
                        response.currentLocation = locations[0]
                        if detectionItem.previousLocation != nil {
                            response.previousLocation = detectionItem.previousLocation
                            response.distanceInterval = response.currentLocation.distance(from: response.previousLocation)
                            if response.distanceInterval >= detectionItem.distanceFilter {
                                if detectionItem.access == .requestWhenInUseAuthorization && UIApplication.shared.applicationState == .background {
                                    if strongSelf.checkPrevious(item: detectionItem) {
                                        detectionItem.locationCompletion(response)
                                    }
                                } else {
                                    detectionItem.locationCompletion(response)
                                }
                                detectionItem.previousLocation = response.currentLocation
                            }
                        } else {
                            response.previousLocation = response.currentLocation
                            response.distanceInterval = 0
                            if detectionItem.access == .requestWhenInUseAuthorization && UIApplication.shared.applicationState == .background {
                                if strongSelf.checkPrevious(item: detectionItem) {
                                    detectionItem.locationCompletion(response)
                                }
                            } else {
                                detectionItem.locationCompletion(response)
                            }
                            detectionItem.previousLocation = response.currentLocation
                        }

                    }
                    
                    if detectionItem.detectStyle != .SignificantLocationChanges {
                        if detectionItem.detectStyle == .Once {
                            if detectionItem.lcoationDetection.locationManager != nil
                            {
                                detectionItem.lcoationDetection.locationManager.stopUpdatingLocation()
                                detectionItem.lcoationDetection.locationManager = nil
                            }
                        } else {
                            if detectionItem.access == .requestAlwaysAuthorization || UIApplication.shared.applicationState == .active {
                                detectionItem.lcoationDetection.locationManager.stopUpdatingLocation()
                                detectionItem.state = "Stop"
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(detectionItem.frequency)) {
                                    guard let manager =  detectionItem.lcoationDetection.locationManager else { return }
                                    manager.startUpdatingLocation()
                                    detectionItem.state = "Start"
                                }
                            }
                        }
                    }
                }
            }
            })
    }
    
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let detectionItem: DetectionInfo = selfManager.regionDetectionList.filter({$0.id == managerId}).first else { return }
        switch status {
        case .authorizedAlways:
            detectionItem.access = .requestAlwaysAuthorization
            if selfManager.backgroundTask == UIBackgroundTaskInvalid {
                selfManager.startBackgroundTask()
            }
            break
        case .authorizedWhenInUse:
            detectionItem.access = .requestWhenInUseAuthorization
            if selfManager.backgroundTask != UIBackgroundTaskInvalid {
                selfManager.endBackgroundTask()
            }
            break
        default:
            break
        }
        detectionItem.authorizationCompletion(status)
    }
    
    internal func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Region monitoring failed: \(region!.identifier)")
    }
    
    internal func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        
    }
    
    internal func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
}
