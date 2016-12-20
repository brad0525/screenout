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
    
    //NUMBER OF NOTIFICAITON
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationNumberLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var locationView: UIView!
    
    
    private var numberUnreadMessage : Int = 0
    private var trackingTimer = NSTimer()
    private var speed = Speed()
    private let timerInterval: NSTimeInterval = 2.0
    private let notificationDelay: NSTimeInterval = 5.0
    private var currentMaxSpeed : Double = 0
    private var startTrackingMaxSpeed : Bool = false
    
    // MARK: View life circle
    
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleMenuButton))
        notificationView.userInteractionEnabled = true
        notificationView.addGestureRecognizer(tap)

        
        // menu
        self.revealViewController().rearViewRevealWidth = self.view.frame.width - 50
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // navigationController
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.navigationBar.translucent = false
        
        //
        notificationView.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UserLocation.sharedInstance.startUpdatingLocation()
        self.startTrackingTimer()
        
        performSelector(#selector(trackPush), withObject: nil, afterDelay: 5.0)
        
        // getUnreadMessage
        getUnreadMessage()
        
        // force update device token to database
        
        if let deviceTokenString = UserDefaultKey.deviceToken {
            APIClient.sharedInstance.pushNotificationKey(deviceTokenString, callbackSucceed: { (dic:NSDictionary) in
                
            }) { (error:String) in
                
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        UserLocation.sharedInstance.stopUpdatingLocation()
        self.stopTrackingTimer()
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: Internal function
    
    internal func dismissLocationView () {
        self.locationView.hidden = true
    }
    
    func getUnreadMessage(){
        
        var deviceToken = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultKey.kDeviceToken) as? String
        if deviceToken == nil {
            deviceToken = ""
        }
        
        
        APIClient.sharedInstance.viewNotifications(deviceToken!, callbackSucceed: { (data:NSDictionary) in
            let result = data.valueForKey("result") as? String
            var unreadCount : Int = 0
            if result == "error" {
                showAlertView(data.valueForKey("message") as! String, viewcontroller: self)
            } else {
                if let tempMessages = data.valueForKey("message") as? Array<NSDictionary> {
                    for dic in tempMessages {
                        if dic["isRead"] as? String == "no" {
                            unreadCount += 1
                        }
                    }
                }
            }
            
            if unreadCount > 0 {
                self.numberUnreadMessage = unreadCount
                self.notificationNumberLabel.text = "\(self.numberUnreadMessage)"
                self.notificationView.hidden = false
            }
            else {
                self.notificationView.hidden = true
            }
            
        }) { (errorMsg:String) in
        }
    }

    internal func toggleMenuButton() {
        let revealViewController = self.revealViewController()
        if (revealViewController != nil) {
            revealViewController.revealToggle(menuButton)
            
            if revealViewController.rearViewController is MenuViewController {
                (revealViewController.rearViewController as! MenuViewController).numberOfUnreadNotification = numberUnreadMessage
                (revealViewController.rearViewController as! MenuViewController).delegate = self
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func menuButtonClicked(sender: AnyObject) {
        toggleMenuButton()
    }
    // MARK: Maxspeed threshold
    
    func fetchUserMaxSpeedWithCompletionHandler(completionHandler:(success: Bool) -> Void) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let queryString = "id=\(Device().uuid)"
        let escapedString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let urlString = "\(Network().url)/threshold.php?" + escapedString!
        
        let task = Network().session!.dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error == nil) {
                
                let jsonObject: AnyObject!
                do {
                    jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                } catch _ as NSError {
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
    
    @IBAction func hideAdmin(_: AnyObject!) {
        if (adminBottomConstraint.constant == 0) {
            adminBottomConstraint.constant = -adminView.frame.size.height
            
        } else {
            adminBottomConstraint.constant = 0
        }
    }
    
    // MARK: Tracking Timer
    
    func startTrackingTimer() {
        trackingTimer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: #selector(checkSpeedAndUpdateAdmin), userInfo: nil, repeats: true)
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
            if startTrackingMaxSpeed == true {
                if self.speed.mph > currentMaxSpeed {
                    currentMaxSpeed = self.speed.mph
                }
            }
            else {
                currentMaxSpeed = 0
            }
            
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
        startTrackingMaxSpeed = false
        let maxSpeed = "\(self.currentMaxSpeed)"
        var longitude = ""
        var latitude = ""
        if let tempLongitude = UserLocation.sharedInstance.currentLocation2d?.longitude {
            longitude = "\(tempLongitude)"
        }
        if let tempLatitude = UserLocation.sharedInstance.currentLocation2d?.latitude {
            latitude = "\(tempLatitude)"
        }
        let isLocked = "\(Device().inactive)"
        let disconnectedStatus = "false"
        let maxSpeedChangeCount = "3"


        APIClient.sharedInstance.push(deviceName, deviceID: deviceID, deviceType: deviceType, action: action, speed: speed, maxSpeed: maxSpeed, latitude: latitude, longitude: longitude, islocked: isLocked, disconnectedStatus: disconnectedStatus, maxSpeedChangeCount: maxSpeedChangeCount, callbackSucceed: { (dic:NSDictionary) in
            
            if let delay = dic["delay"] as? String {
                self.startTrackingMaxSpeed = true
                self.performSelector(#selector(self.trackPush), withObject: nil, afterDelay: Double(delay)!)
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
            
            showProgressHUD(self)
            
            APIClient.sharedInstance.homebase("\(latitude)", longitude : "\(longitude)", callbackSucceed: { (dic:NSDictionary) in
                hideProgressHUD(self)
                self.locationView.hidden = false
                NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.dismissLocationView), userInfo: nil, repeats: false)
            
                }, callbackError: { (error:String) in
                    hideProgressHUD(self)
                    let alert = UIAlertView(title: "An error has occurred", message: "Your current location was not set on the server.", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
            })
        } else {
            // pop alert with location unavailable yet
            
            let alert = UIAlertView(title: "Location Unavailable", message: "Location services unavailable. Please try again shortly.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    
    }
    
    func trackAction(action: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let queryString = "name=\(Device().name)&id=\(Device().uuid)&action=\(action)&isLocked=\(Device().state)"
        let escapedString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let urlString = "\(Network().url)/data.php?" + escapedString!
        
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
                
                let queryString = "name=\(Device().name)&id=\(Device().uuid)&action=\(action)&speed=\(self.speed.mph)&maxspeed=\(self.speed.max)&lat=\(latitude)&long=\(longitude)&isLocked=\(Device().inactive)"
                let escapedString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
                let urlString = "\(Network().url)/data.php?" + escapedString!
                
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

// MARK: MenuViewControllerDelegate
extension DashboardViewController : MenuViewControllerDelegate {
    
    func didClickHomeButon() {
        toggleMenuButton()
    }
    
    func didClickNotificationButton() {
        toggleMenuButton()
        let messageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MessageViewController")
        self.navigationController?.pushViewController(messageViewController, animated: true)
    }
    
    func didClickSupportButton() {
        toggleMenuButton()
        let feedback = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FeedbackViewController") as! FeedbackViewController
        self.navigationController?.pushViewController(feedback, animated: true)
    }
    
    func didClickSetLocationButton() {
        toggleMenuButton()
        trackCheckin()
    }
}