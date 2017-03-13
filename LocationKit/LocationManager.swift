//
//  LocationManger.swift
//  LocationKit
//
//  Created by JoeJoe on 2016/12/28.
//  Copyright © 2016年 Joe. All rights reserved.
//

import Foundation
import CoreLocation

public class LocationManager: NSObject {
    var regionDetectionList: [DetectionInfo] = []
    open var requestAccess: RequestAccess = .requestAlwaysAuthorization
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    public override init () {
        //print("LocationKit has been initialised")
        for i in 1...10 {
            let item: DetectionInfo = DetectionInfo()
            item.lcoationDetection = LocationDetection()
            item.id = i
            item.identification = "LocationKitDefault" + i.description
            regionDetectionList.append(item)
        }
    }
    
    public init (detectInstanceNumber: Int) {
        //print("LocationKit has been initialised")
        for i in 1...detectInstanceNumber {
            let item: DetectionInfo = DetectionInfo()
            item.lcoationDetection = LocationDetection()
            item.id = i
            item.identification = "LocationKitDefault" + i.description
            regionDetectionList.append(item)
        }
    }

    open func getLocation(detectStyle: DetectStyle = .UpdatingLocation, distanceFilter: Double = kCLHeadingFilterNone, locationAccuracy: LocationAccuracy = .Best, detectFrequency: Int = 5, identification: String = "LocationKitDefault", completion: @escaping (_ Location: JLocationResponse)->(), error: ((_ ErrorMessage: String) -> Void)? = {_ in}, authorizationChange: ((_ Status: CLAuthorizationStatus) -> Void)? = {_ in}) {
        if regionDetectionList.contains(where: {$0.identification == identification}) {
            error!("The identification is duplicated.")
            return
        }
        let list = regionDetectionList.filter({$0.lcoationDetection.locationManager == nil })
        if list.count > 0 {
            let item: DetectionInfo = list.first!
            if identification != "LocationKitDefault" {
                item.identification = identification
            } else {
                 item.identification = "LocationKitDefault" + item.id.description
            }
            item.detectStyle = detectStyle
            item.access = requestAccess
            item.state = "Start"
            item.accuracy = locationAccuracy
            item.distanceFilter = distanceFilter
            item.frequency = detectFrequency
            item.style = "DetectStyle"
            item.lcoationDetection.startLocationDetection(manger: self, detectionItem: item)
            item.locationCompletion = completion
            item.authorizationCompletion = authorizationChange!
        } else {
            error!("Instances is out of range, please increase the detectInstanceNumber")
        }
    }

    open func regionNotify(notifyStyle: NotifyStyle = .MonitoringRegion, distanceFilter: Double = kCLHeadingFilterNone, locations: [JLocation], locationAccuracy: LocationAccuracy = .Best, detectFrequency: Int = 5, identification: String = "LocationKitDefault", completion: @escaping (_ Region: JRegion)->(), error: ((_ ErrorMessage: String) -> Void)? = {_ in}, authorizationChange: ((_ Status: CLAuthorizationStatus) -> Void)? = {_ in}) {
        if regionDetectionList.contains(where: {$0.identification == identification}) {
            error!("The identification is duplicated!")
            return
        }
        if locations.count == 0 {
            error!("Non target location!")
            return
        }
        let list = regionDetectionList.filter({$0.lcoationDetection.locationManager == nil })
        if list.count > 0 {
            let item: DetectionInfo = list.first!
            if identification != "LocationKitDefault" {
                item.identification = identification
            } else {
                item.identification = "LocationKitDefault" + item.id.description
            }
            item.notifyStyle = notifyStyle
            item.access = requestAccess
            item.state = "Start"
            item.accuracy = locationAccuracy
            item.distanceFilter = distanceFilter
            item.frequency = detectFrequency
            item.style = "NotifyStyle"
            item.locationList = locations
            item.lcoationDetection.startLocationDetection(manger: self, detectionItem: item)
            item.regionCompletion = completion
            item.authorizationCompletion = authorizationChange!
        } else {
            error!("Instances is out of range, please increase the detectInstanceNumber!")
        }
    }
    
    open func stopAll() {
        if regionDetectionList.count > 0 {
            for detectionItem in regionDetectionList {
                if detectionItem.lcoationDetection.locationManager != nil {
                    switch detectionItem.style {
                    case "NotifyStyle":
                        switch detectionItem.notifyStyle as NotifyStyle {
                        case NotifyStyle.MonitoringRegion:
                            for item in detectionItem.regionList {
                                detectionItem.lcoationDetection.locationManager.stopMonitoring(for: item)
                            }
                            break
                        case NotifyStyle.UpdatingLocation:
                            detectionItem.lcoationDetection.locationManager.stopUpdatingLocation()
                            break
                        case NotifyStyle.SignificantLocationChanges:
                            detectionItem.lcoationDetection.locationManager.stopMonitoringSignificantLocationChanges()
                            break
                        }
                        break
                    case "DetectStyle":
                        switch detectionItem.detectStyle as DetectStyle {
                        case DetectStyle.UpdatingLocation, DetectStyle.Once:
                            detectionItem.lcoationDetection.locationManager.stopUpdatingLocation()
                            break
                        case DetectStyle.SignificantLocationChanges:
                            detectionItem.lcoationDetection.locationManager.stopMonitoringSignificantLocationChanges()
                            break
                        }
                        break
                    default:
                        break
                    }
                    detectionItem.lcoationDetection.locationManager = nil
                    detectionItem.identification = "LocationKitDefault" + detectionItem.id.description
                }
            }
        }
    }
    
    open func stop(identification: String) {
        let list = regionDetectionList.filter({$0.identification == identification })
        if list.count > 0 {
            let detectionItem: DetectionInfo = list.first!
            if detectionItem.lcoationDetection.locationManager != nil {
                switch detectionItem.style {
                case "NotifyStyle":
                    switch detectionItem.notifyStyle as NotifyStyle {
                    case NotifyStyle.MonitoringRegion:
                        for item in detectionItem.regionList {
                            detectionItem.lcoationDetection.locationManager.stopMonitoring(for: item)
                        }
                        break
                    case NotifyStyle.UpdatingLocation:
                        detectionItem.lcoationDetection.locationManager.stopUpdatingLocation()
                        break
                    case NotifyStyle.SignificantLocationChanges:
                        detectionItem.lcoationDetection.locationManager.stopMonitoringSignificantLocationChanges()
                        break
                    }
                    break
                case "DetectStyle":
                    switch detectionItem.detectStyle as DetectStyle {
                    case DetectStyle.UpdatingLocation, DetectStyle.Once:
                        detectionItem.lcoationDetection.locationManager.stopUpdatingLocation()
                        break
                    case DetectStyle.SignificantLocationChanges:
                        detectionItem.lcoationDetection.locationManager.stopMonitoringSignificantLocationChanges()
                        break
                    }
                    break
                default:
                    break
                }
                detectionItem.lcoationDetection.locationManager = nil
                detectionItem.identification = "LocationKitDefault" + detectionItem.id.description
            }
        } else {
            print("Can't find this identification!")
        }
    }
    
    internal func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    internal func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
}
