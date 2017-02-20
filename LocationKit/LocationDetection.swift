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
                //locationManager.distanceFilter = detectionItem.distanceFilter
                locationManager.startUpdatingLocation()
                break
            case NotifyStyle.SignificantLocationChanges:
                locationManager.startMonitoringSignificantLocationChanges()
                break
            }
            break
        case "DetectStyle":
            //locationManager.distanceFilter = detectionItem.distanceFilter
            if #available(iOS 9.0, *) {
                if detectionItem.allowsBackground {
                    locationManager.allowsBackgroundLocationUpdates = true
                } else {
                    locationManager.allowsBackgroundLocationUpdates = false
                }
            }
            switch detectionItem.detectStyle as DetectStyle {
            case DetectStyle.UpdatingLocation, DetectStyle.Once:
                locationManager.startUpdatingLocation()
                break
            case DetectStyle.SignificantLocationChanges:
                //locationManager.distanceFilter = 0
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
    
    private func setRegion(detectionItem: DetectionInfo){
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
    
    private func getPrevious(item: DetectionInfo, style: RegionState) -> Int{
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
    
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    internal func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        
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
                            regionItem.previousEnterDate = detectionItem.insideDatetime
                            regionItem.previousEnterIntervalSec = strongSelf.getPrevious(item: detectionItem, style: .inside)
                            if regionItem.previousEnterIntervalSec == 0 {
                                regionItem.firstNotify = true
                            } else {
                                regionItem.firstNotify = false
                            }
                            detectionItem.regionCompletion(regionItem)
                            break
                        case .outside:
                            regionItem.regionState = .outside
                            regionItem.previousEnterDate = detectionItem.insideDatetime
                            regionItem.previousEnterIntervalSec = strongSelf.getPrevious(item: detectionItem, style: .outside)
                            if regionItem.previousEnterIntervalSec == 0 {
                                regionItem.firstNotify = true
                            } else {
                                regionItem.firstNotify = false
                            }
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
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Region monitoring failed: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {

        }
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
                                        regionItem.previousEnterDate = detectionItem.insideDatetime
                                        regionItem.previousEnterIntervalSec = strongSelf.getPrevious(item: detectionItem, style: .inside)
                                        if regionItem.previousEnterIntervalSec == 0 {
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
                                        regionItem.previousEnterDate = detectionItem.outsideDatetime
                                        regionItem.previousEnterIntervalSec = strongSelf.getPrevious(item: detectionItem, style: .outside)
                                        if regionItem.previousEnterIntervalSec == 0 {
                                            regionItem.firstNotify = true
                                        } else {
                                            regionItem.firstNotify = false
                                        }
                                        detectionItem.regionCompletion(regionItem)
                                    }
                                }
                            })
                        }
                    }
                    if detectionItem.notifyStyle == .UpdatingLocation {
                        detectionItem.lcoationDetection.locationManager.stopUpdatingLocation()
                        detectionItem.state = "Stop"
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(detectionItem.frequency)) {
                            guard let manager =  detectionItem.lcoationDetection.locationManager else { return }
                            manager.startUpdatingLocation()
                            detectionItem.state = "Start"
                        }
                    }
                } else {
                    if detectionItem.detectStyle != .SignificantLocationChanges {
                        detectionItem.lcoationDetection.locationManager.stopUpdatingLocation()
                        detectionItem.state = "Stop"
                        if detectionItem.detectStyle == .Once {
                            detectionItem.lcoationDetection.locationManager = nil
                            detectionItem.identification = "LocationKitDefault" + detectionItem.id.description
                        } else if detectionItem.detectStyle == .UpdatingLocation {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(detectionItem.frequency)) {
                                guard let manager =  detectionItem.lcoationDetection.locationManager else { return }
                                manager.startUpdatingLocation()
                                detectionItem.state = "Start"
                            }
                        }
                    }
                    
                    var response: JLocationResponse = JLocationResponse()
                    response.currentLocation = locations[0]
                    if detectionItem.previousLocation != nil {
                        response.previousLocation = detectionItem.previousLocation
                        response.distanceInterval = response.currentLocation.distance(from: response.previousLocation)
                        if response.distanceInterval >= detectionItem.distanceFilter {
                            detectionItem.locationCompletion(response)
                        }
                    } else {
                        response.previousLocation = response.currentLocation
                        response.distanceInterval = 0
                        detectionItem.locationCompletion(response)
                    }
                    detectionItem.previousLocation = response.currentLocation

                }
            }
            })
    }
    
    internal func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
}
