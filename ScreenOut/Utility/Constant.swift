//
//  Constant.swift
//  ScreenOut
//
//  Created by Hoang on 4/4/16.
//  Copyright © 2016 Eric Rohlman. All rights reserved.
//

import UIKit


struct Network {
    var url = "https://screenout.datadesignsystems.com"
    var session: NSURLSession? {
        get {
            
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            sessionConfig.HTTPMaximumConnectionsPerHost = 2
            sessionConfig.timeoutIntervalForRequest = 5
            return NSURLSession(configuration: sessionConfig)
        }
    }
}

struct Device {
    var uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString
    var name = UIDevice.currentDevice().name
    var state = UIApplication.sharedApplication().applicationState
    var inactive = UIApplication.sharedApplication().applicationState == .Inactive
    
    
    
}

struct Speed {
    var current = 0.0
    var max = 5.0
    var mph: Double {
        get {
            if current < 0 {
                return 0
            }
            
            // 1 m/s = 2.2369362920544025 m/h
            return current * 2.2369362920544025
        }
    }
}

//
// Key is used with notes.php
//

struct MessageKey {
    static let kID = "id"
    static let kNotification = "notification"
    static let kIsRead = "isRead"
    static let kDateRead = "dateRead"
}

//
// Key to save NSUserDefault
//

struct UserDefaultKey {
    static let kDeviceToken = "kDeviceToken"
}


//
// Progress view
//

func showProgressHUD(viewController:UIViewController){
    MBProgressHUD.showHUDAddedTo(viewController.view, animated: true)
}

func hideProgressHUD(viewController:UIViewController){
    MBProgressHUD.hideHUDForView(viewController.view, animated: true)
}

func showAlertView(message:String, viewcontroller:UIViewController){
    let alert = UIAlertController(title: "ScreenOut", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
    viewcontroller.presentViewController(alert, animated: true, completion: nil)
}

