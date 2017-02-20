//
//  LocationModel.swift
//  LocationKit
//
//  Created by JoeJoe on 2017/1/13.
//  Copyright © 2017年 Joe. All rights reserved.
//

import Foundation
import CoreLocation

typealias detectCompletionHandler = (_ Location: JLocationResponse) -> Void
typealias regionCompletionHandler = (_ Region: JRegion) -> Void
internal var detectCompletionAssociationKey: UInt8 = 0
internal var regionCompletionAssociationKey: UInt8 = 0

class DetectCompletionWrapper {
    var completion: (detectCompletionHandler)?
    
    init(_ completion: (detectCompletionHandler)?) {
        self.completion = completion
    }
}

class RegionCompletionWrapper {
    var completion: (regionCompletionHandler)?
    
    init(_ completion: (regionCompletionHandler)?) {
        self.completion = completion
    }
}

public enum RegionState {
    case inside
    case outside
    
    public func description() -> String {
        switch self {
        case .inside:
            return "inside"
        case .outside:
            return "outside"
        }
    }
}

public enum DetectStyle {
    case UpdatingLocation
    case SignificantLocationChanges
    case Once
}

public enum RequestAccess {
    case requestWhenInUseAuthorization
    case requestAlwaysAuthorization
}

public enum LocationAccuracy {
    case BestForNavigation
    case Best
    case NearestTenMeters
    case HundredMeters
    case Kilometer
    case ThreeKilometers
}

public enum NotifyStyle {
    case UpdatingLocation
    case SignificantLocationChanges
    case MonitoringRegion
}

public class JLocation:CLLocation {
    public var locationRadius: Double!
    public var locationIdentifier: String!
    public convenience init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: Double, identifier: String){
        self.init(latitude: latitude, longitude: longitude)
        locationRadius = radius
        locationIdentifier = identifier
    }
}

public class JLocationResponse {
    public var currentLocation: CLLocation!
    public var previousLocation: CLLocation!
    public var distanceInterval: Double!
}

public class JRegion:CLCircularRegion {
    public var regionRadius: Double!
    public var regionIdentifier: String!
    public var regionState: RegionState!
    public var previousEnterIntervalSec: Int! = 0
    public var previousEnterDate: Date!
    public var firstNotify: Bool = false
    internal var insideActive: Bool = false
    public convenience init(centerPoint: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String){
        self.init(center: centerPoint, radius: radius, identifier: identifier)
        regionRadius = radius
        regionIdentifier = identifier
    }
}

class DetectionInfo {
    var lcoationDetection: LocationDetection!
    var regionCompletion: regionCompletionHandler {
        get {
            return (objc_getAssociatedObject(self, &regionCompletionAssociationKey) as? RegionCompletionWrapper)!.completion!
        }
        set(newValue) {
            objc_setAssociatedObject(self, &regionCompletionAssociationKey,  RegionCompletionWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    var locationCompletion: detectCompletionHandler {
        get {
            return (objc_getAssociatedObject(self, &detectCompletionAssociationKey) as? DetectCompletionWrapper)!.completion!
        }
        set(newValue) {
            objc_setAssociatedObject(self, &detectCompletionAssociationKey,  DetectCompletionWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    internal var id: Int!
    internal var identification: String!
    internal var access: RequestAccess!
    internal var accuracy: LocationAccuracy!
    internal var notifyStyle: NotifyStyle!
    internal var detectStyle: DetectStyle!
    internal var distanceFilter: Double!
    internal var frequency: Int!
    internal var allowsBackground: Bool = false
    internal var insideDatetime: Date!
    internal var outsideDatetime: Date!
    internal var locationList: [JLocation] = []
    internal var regionList: [JRegion] = []
    internal var style: String!
    internal var state: String!
    internal var previousLocation: CLLocation!
}
