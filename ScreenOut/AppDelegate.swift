//
//  AppDelegate.swift
//  ScreenOut
//
//  Created by Eric Rohlman on 9/19/14.
//  Copyright (c) 2014 Eric Rohlman. All rights reserved.
//

import UIKit
import AirshipKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let config = UAConfig.defaultConfig()
        UAirship.takeOff(config)
        UAirship.push().userPushNotificationsEnabled = true
        UAirship.push()
        
        return true
    }
    
    func registerUAirshipAndPushNotification() {
        
        
        let application = UIApplication.sharedApplication()
        application.idleTimerDisabled = true
        application.cancelAllLocalNotifications()
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert], categories: nil))
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

        let characterSet: NSCharacterSet = NSCharacterSet(charactersInString: "<>")
        
        let deviceTokenString: String = (deviceToken.description as NSString).stringByTrimmingCharactersInSet(characterSet).stringByReplacingOccurrencesOfString( " ", withString: "") as String
        
        // save device token
        NSUserDefaults.standardUserDefaults().setObject(deviceTokenString, forKey: UserDefaultKey.kDeviceToken)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        if UserDefaultKey.apikey != nil {
            APIClient.sharedInstance.pushNotificationKey(deviceTokenString, callbackSucceed: { (dic:NSDictionary) in
                
            }) { (error:String) in
                
            }
        }
        
        /*
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let queryString = "deviceId=\(Device().name)&token=\(deviceTokenString)"
        let escapedString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let urlString = "\(Network().url)/deviceInformation.php?" + escapedString!
        let task = Network().session!.dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    // register successfully
                    // todo
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    // can not register
                    // todo
                })
            }
        })
        task.resume()
         */
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let dic = userInfo["aps"]  {
            if application.applicationState == .Active {
                showAlertView(dic.valueForKey("alert") as! String, viewcontroller: window!.rootViewController!)
            } else {
                
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        application.cancelAllLocalNotifications()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

