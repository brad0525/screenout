//
//  DashboardViewController.swift
//  ScreenOut
//
//  Created by Eric Rohlman on 9/19/14.
//  Copyright (c) 2014 Eric Rohlman. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import MapKit

class DashboardViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var adminView: UIView!
    @IBOutlet weak var adminBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    private var trackingTimer = NSTimer()
    private var speed = Speed()
    private let timerInterval: NSTimeInterval = 2.0
    private let notificationDelay: NSTimeInterval = 5.0
    var messageViewController:MessageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserMaxSpeedWithCompletionHandler({(success: Bool) -> Void in
            if (success) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.maxSpeedLabel.text = "Speed (\(self.speed.max))"
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alert = UIAlertView(title: "User threshold failed", message: "The default value (\(self.speed.max)) will be used instead", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                })
            }
        })
        
        // load applicationIconBadgeNumber when first load view.
        messageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MessageViewController") as? MessageViewController
        messageViewController?.getMessage()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UserLocation.sharedInstance.startUpdatingLocation()
        self.startTrackingTimer()
        
        performSelector(#selector(trackPush), withObject: nil, afterDelay: 5.0)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        UserLocation.sharedInstance.stopUpdatingLocation()
        self.stopTrackingTimer()
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK:
    
    
    // MARK: Maxspeed threshold
    
    func fetchUserMaxSpeedWithCompletionHandler(completionHandler:(success: Bool) -> Void) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        var queryString = "id=\(Device().uuid)"
        var escapedString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        var urlString = "\(Network().url)/threshold.php?" + escapedString!
        
        let task = Network().session!.dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error == nil) {
                var jsonError: NSError?
                let jsonObject: AnyObject!
                do {
                    jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                } catch var error as NSError {
                    jsonError = error
                    jsonObject = nil
                } catch {
                    fatalError()
                }
                if let speedArray = jsonObject as? NSArray {
                    if let dict = speedArray[0] as? NSDictionary {
                        if let theMax = dict["maxspeed"] as? NSString {
                            self.speed.max = theMax.doubleValue
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completionHandler(success: true)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completionHandler(success: false)
                })
            }
        })
        task.resume()
    }
    
    @IBAction func sendCheckinTapped(sender:AnyObject!) {
        self.trackCheckin()
    }
    
    @IBAction func openFeedback(sender:AnyObject!) {
        let feedback = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FeedbackViewController") as! FeedbackViewController
        self.navigationController?.pushViewController(feedback, animated: true)
    }
    
    @IBAction func hideAdmin(_: AnyObject!) {
        if (adminBottomConstraint.constant == 0) {
            adminBottomConstraint.constant = -adminView.frame.size.height
            
        } else {
            adminBottomConstraint.constant = 0
        }
    }
    
    @IBAction func messageButtonClicked(sender: AnyObject) {
        messageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MessageViewController") as? MessageViewController
        self.navigationController?.pushViewController(messageViewController!, animated: true)
    }
    
    // MARK: Tracking Timer
    
    func startTrackingTimer() {
        trackingTimer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: Selector("checkSpeedAndUpdateAdmin"), userInfo: nil, repeats: true)
    }
    
    func stopTrackingTimer() {
        trackingTimer.invalidate()
    }
    
    func checkSpeedAndUpdateAdmin() {
        // update admin
        if let latitude = UserLocation.sharedInstance.currentLocation2d?.latitude {
            latitudeLabel.text = "\(latitude)"
        }
        
        if let longitude = UserLocation.sharedInstance.currentLocation2d?.longitude {
            longitudeLabel.text = "\(longitude)"
        }
        
        if let speed = UserLocation.sharedInstance.currentSpeed {
            self.speed.current = speed
            speedLabel.text = "\(round(self.speed.mph))"
        }

        // speed check
        if (self.speed.mph > self.speed.max) {
            enableScreenOutWithNotification()
        } else {
            disableScreenOut()
        }
    }
    
    
    // MARK: Tracking Action
    
    func trackPush() {
        let deviceName = Device().name
        let deviceID = Device().uuid
        let deviceType = UIDevice.currentDevice().modelName
        let action = "Speed Change"
        let speed = "\(self.speed.mph)"
        let maxSpeed = "\(self.speed.max)"
        var longitude = ""
        var latitude = ""
        if let tempLongitude = UserLocation.sharedInstance.currentLocation2d?.longitude {
            longitude = "\(tempLongitude)"
        }
        if let tempLatitude = UserLocation.sharedInstance.currentLocation2d?.latitude {
            latitude = "\(tempLatitude)"
        }
        let isLocked = "\(Device().inactive)"
        let disconnectedStatus = "true"
        let maxSpeedChangeCount = "3"
        


        APIClient.sharedInstance.push(deviceName, deviceID: deviceID, deviceType: deviceType, action: action, speed: speed, maxSpeed: maxSpeed, latitude: latitude, longitude: longitude, islocked: isLocked, disconnectedStatus: disconnectedStatus, maxSpeedChangeCount: maxSpeedChangeCount, callbackSucceed: { (dic:NSDictionary) in
            
            if let delay = dic["delay"] as? Double {
                self.performSelector(#selector(self.trackPush), withObject: nil, afterDelay: delay)
            }
            
        }) { (error:NSDictionary) in
            if let code = error["code"] as? String {
                if let errorMessage = error["message"] as? String {
                    if code == "401" {
                        let alert = UIAlertController(title: "ScreenOut", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alert:UIAlertAction) in
                            exit(0)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    else {
                        showAlertView(errorMessage, viewcontroller: self)
                    }
                }
            }
        }
    }
    
    func trackCheckin() {
        
        if let currentLocation = UserLocation.sharedInstance.currentLocation2d {
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let longitude = currentLocation.longitude
            let latitude = currentLocation.latitude
            
            var queryString = "name=\(Device().name)&id=\(Device().uuid)&long=\(longitude)&lat=\(latitude)&key=549034ea50c6a6ccfc25a49f&isLocked=\(Device().state)"
            var escapedString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
            var urlString = "\(Network().url)/homebase.php?" + escapedString!
            
            let task = Network().session!.dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if (error == nil) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        
                        var alert = UIAlertView(title: "Coordinates sent successfully", message: "Your current location has been set on the server.", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        
                        var alert = UIAlertView(title: "An error has occurred", message: "Your current location was not set on the server.", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    })
                }
            })
            task.resume()
            
        } else {
            // pop alert with location unavailable yet
            
            var alert = UIAlertView(title: "Location Unavailable", message: "Location services unavailable. Please try again shortly.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func trackAction(action: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        var queryString = "name=\(Device().name)&id=\(Device().uuid)&action=\(action)&isLocked=\(Device().state)"
        var escapedString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        var urlString = "\(Network().url)/data.php?" + escapedString!
        
        let task = Network().session!.dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
        })
        task.resume()
    }
    
    func trackSpeedWithAction(action: String) {
        if let latitude = UserLocation.sharedInstance.currentLocation2d?.latitude {
            if let longitude = UserLocation.sharedInstance.currentLocation2d?.longitude {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                
                var queryString = "name=\(Device().name)&id=\(Device().uuid)&action=\(action)&speed=\(self.speed.mph)&maxspeed=\(self.speed.max)&lat=\(latitude)&long=\(longitude)&isLocked=\(Device().inactive)"
                var escapedString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
                var urlString = "\(Network().url)/data.php?" + escapedString!
                
                let task = Network().session!.dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    })
                })
                task.resume()
            }
        }
    }
    
    
    // MARK: ScreenOut
    
    func enableScreenOutWithNotification() {
        UIAccessibilityRequestGuidedAccessSession(true, { (didSucceed) -> Void in
            if (didSucceed) {
                //
            }
        })
        
        let localNotif = UILocalNotification()
        localNotif.fireDate = NSDate().dateByAddingTimeInterval(notificationDelay)
        localNotif.alertBody = "ScreenOut Enabled"
        localNotif.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotif)
        
        imageView.highlighted = true
        trackSpeedWithAction("ScreenOut activated")
    }
    
    func disableScreenOut() {
        UIAccessibilityRequestGuidedAccessSession(false, { (didSucceed) -> Void in
            if (didSucceed) {
                //
            }
        })
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        imageView.highlighted = false
        trackSpeedWithAction("ScreenOut deactivated")
    }
}