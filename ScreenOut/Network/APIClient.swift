//
//  APIClient.swift
//  ScreenOut
//
//  Created by Hoang on 9/22/16.
//  Copyright © 2016 Eric Rohlman. All rights reserved.
//

import UIKit

class APIClient {
    static let sharedInstance = APIClient()
    
    private var baseURL = "https://api.managesync.com/screenout/"
    private var verifyUserCodeAPI = "verify-user-code/"
    private var pushAPI = "push/"
    private var pushNotificationKeyAPI = "push-notification-key/"
    private var homebaseAPI = "homebase/"
    private var commentsAPI = "comments/"
    private var viewNotificationsAPI = "view-notifications/"
    private var markNotificationReadAPI = "mark-notification-read/"
    
    private func dataToDict(data: NSData?) -> NSDictionary {
        if let theData = data {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(theData, options: .MutableLeaves) as? NSDictionary
                if let theDict = json {
                    return theDict
                }
            }catch let error as NSError {
                #if DEBUG
                    print("dataToDict: json error: \(error)")
                #endif
            }
        }
        return NSDictionary()
    }
    
    private func postForDict(url: NSURL, callbackSucceed: (NSDictionary) -> (), callbackError: (NSError) -> ()) -> Void {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let task = Network().session!.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            
            dispatch_async(dispatch_get_main_queue(),{
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if error == nil {
                    let dic = self.dataToDict(data)
                    callbackSucceed(dic)
                }
                else {
                    callbackError(error!)
                }
            })
        }
        task.resume()
    }

    
    func verifyUserCode(code:String, callbackSucceed: (NSDictionary) -> (), callbackError: (String) -> ()) {
        
        let queryString = (baseURL + verifyUserCodeAPI) + "data?code=\(code)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: queryString)!
        
        postForDict(url, callbackSucceed: { (dic:NSDictionary) in
            if let data = dic["data"] as? NSDictionary {
                if let code = data["responseCode"] as? String where code == "301" {
                    callbackError(data["description"] as! String)
                }
                else {
                    callbackSucceed(data)
                }
            }
        }) { (error:NSError) in
            callbackError(error.localizedDescription)
        }
    }
    
    func push(deviceName:String, deviceID:String, deviceType:String, action:String, speed:String, maxSpeed: String, latitude: String, longitude: String, islocked:String, disconnectedStatus:String, maxSpeedChangeCount:String, callbackSucceed: (NSDictionary) -> (), callbackError: (NSDictionary) -> ()) {
        
        let queryString = (baseURL + pushAPI) + "\(UserDefaultKey.apikey!)/" + "data?deviceName=\(deviceName)&deviceid=\(deviceID)&deviceType=\(deviceType)&action=\(action)&speed=\(speed)&maxspeed=\(maxSpeed)&latitude=\(latitude)&longitude=\(longitude)&islocked=\(islocked)&disconnectedStatus=\(disconnectedStatus)&maxSpeedChangeCount=\(maxSpeedChangeCount)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: queryString)!
        
        postForDict(url, callbackSucceed: { (dic:NSDictionary) in
            #if DEBUG
                print(dic)
            #endif
            if let data = dic["data"] as? NSDictionary {
                if let code = data["code"] as? String where code == "201" {
                    callbackSucceed(data)
                }
                else {
                    callbackError(data)
                }
            }
        }) { (error:NSError) in
            callbackError(["message" : error.localizedDescription, "code" : error.code])
            
        }
    }
    
    func pushNotificationKey(token:String, callbackSucceed: (NSDictionary) -> (), callbackError: (String) -> ()) {
        
        let queryString = (baseURL + pushNotificationKeyAPI) + "\(UserDefaultKey.apikey!)/" + "data?token=\(token)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: queryString)!
        
        postForDict(url, callbackSucceed: { (dic:NSDictionary) in
            if let data = dic["data"] as? NSDictionary {
                if let code = data["responseCode"] as? String where code == "301" {
                    callbackError(data["description"] as! String)
                }
                else {
                    callbackSucceed(data)
                }
            }
        }) { (error:NSError) in
            callbackError(error.localizedDescription)
        }
    }
    
    func homebase(latitude: String, longitude: String, callbackSucceed: (NSDictionary) -> (), callbackError: (String) -> ()) {
        
        let queryString = (baseURL + homebaseAPI) + "\(UserDefaultKey.apikey!)/" + "data?latitude=\(latitude)&longitude=\(longitude)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: queryString)!
        
        postForDict(url, callbackSucceed: { (dic:NSDictionary) in
            if let data = dic["data"] as? NSDictionary {
                if let code = data["responseCode"] as? String where code == "301" {
                    callbackError(data["description"] as! String)
                }
                else {
                    callbackSucceed(data)
                }
            }
        }) { (error:NSError) in
            callbackError(error.localizedDescription)
        }
    }
    
    
    
    func comments(email: String, comments: String, callbackSucceed: (NSDictionary) -> (), callbackError: (String) -> ()) {
        
        let queryString = (baseURL + commentsAPI) + "\(UserDefaultKey.apikey!)/" + "data?email=\(email)&comments=\(comments)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: queryString)!
        
        postForDict(url, callbackSucceed: { (dic:NSDictionary) in
            if let data = dic["data"] as? NSDictionary {
                if let code = data["responseCode"] as? String where code == "301" {
                    callbackError(data["description"] as! String)
                }
                else {
                    callbackSucceed(data)
                }
            }
        }) { (error:NSError) in
            callbackError(error.localizedDescription)
        }
    }
    
    func viewNotifications(push: String, callbackSucceed: (NSDictionary) -> (), callbackError: (String) -> ()) {
        
        let queryString = (baseURL + viewNotificationsAPI) + "\(UserDefaultKey.apikey!)/" + "data?push=\(push)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: queryString)!
        
        postForDict(url, callbackSucceed: { (dic:NSDictionary) in
            if let data = dic["data"] as? NSDictionary {
                #if DEBUG
                    print(data)
                #endif
                if let code = data["responseCode"] as? String where code == "301" {
                    callbackError(data["description"] as! String)
                }
                else {
                    callbackSucceed(data)
                }
            }
        }) { (error:NSError) in
            callbackError(error.localizedDescription)
        }
    }
    
    func markNotificationRead(messageID: String, isRead: String, callbackSucceed: (NSDictionary) -> (), callbackError: (String) -> ()) {
        
        let queryString = (baseURL + markNotificationReadAPI) + "\(UserDefaultKey.apikey!)/" + "data?messageId=\(messageID)&isRead=\(isRead)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: queryString)!
        
        postForDict(url, callbackSucceed: { (dic:NSDictionary) in
            print(dic)
            if let data = dic["data"] as? NSDictionary {
                if let code = data["responseCode"] as? String where code == "301" {
                    callbackError(data["description"] as! String)
                }
                else {
                    callbackSucceed(data)
                } 
            }
            else {
                callbackError("Unknown error")
            }
        }) { (error:NSError) in
            callbackError(error.localizedDescription)
        }
    }
    
}