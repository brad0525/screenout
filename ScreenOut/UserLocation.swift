//
//  UserLocation.swift
//  ScreenOut
//
//  Created by Eric Rohlman on 9/27/14.
//  Copyright (c) 2014 Eric Rohlman. All rights reserved.
//

import CoreLocation
import Foundation

class UserLocation: NSObject, CLLocationManagerDelegate
{
    class var sharedInstance : UserLocation {
    struct Static {
        static let instance : UserLocation = UserLocation()
        }
        return Static.instance
    }
    
    // MARK: Public class vars
    var currentSpeed: Double?
    var currentLocation2d: CLLocationCoordinate2D?
    var currentHeading: CLHeading?
    
    // MARK: Private class vars
    private var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    // MARK: Public class methods
    func requestAuthorizedWhenInUseAccess() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        let notif = NSNotification(name: "AuthorizationDidChange", object: self, userInfo: nil);
        NSNotificationCenter.defaultCenter().postNotification(notif)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location: CLLocation = locations.last! as CLLocation
        currentLocation2d = location.coordinate
        currentSpeed = location.speed
        
        var notif = NSNotification(name: "UserLocationDidChange", object: self, userInfo: nil);
        NSNotificationCenter.defaultCenter().postNotification(notif)
    }
    
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        return true
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        currentHeading = newHeading
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //
    }
}
