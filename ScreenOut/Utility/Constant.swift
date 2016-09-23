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
    static let userDefault = NSUserDefaults.standardUserDefaults()
    static let kDeviceToken = "kDeviceToken"
    static let kapikey = "apikey"
    
    static var apikey : String? {
        get {
            return userDefault.objectForKey(kapikey) as? String
        }
        set {
            userDefault.setObject(newValue, forKey: kapikey)
            userDefault.synchronize()
        }
    }
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

//
// Extension
//

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

