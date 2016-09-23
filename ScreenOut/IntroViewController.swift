//
//  IntroViewController.swift
//  ScreenOut
//
//  Created by Eric Rohlman on 9/27/14.
//  Copyright (c) 2014 Eric Rohlman. All rights reserved.
//

import UIKit
import CoreLocation

class IntroViewController: UIViewController {
    @IBOutlet weak var alertContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UserDefaultKey.apikey != nil) {
            self.alertContainerView.alpha = 1
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.registerUAirshipAndPushNotification()
        }
        else {
            checkAPIKey()
        }
    }
    
    func checkAPIKey() {
        let alertController = UIAlertController(title: "Please input code to access ScreenOut", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let saveAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            var code = ""
//            #if DEBUG
//                code = "6s0K8980"
//            #else
                code = firstTextField.text!
//            #endif
            APIClient.sharedInstance.verifyUserCode(code, callbackSucceed: { (dic:NSDictionary) in
                
                if let apikey = dic["apikey"] as? String {
                    UserDefaultKey.apikey = apikey
                }
                self.alertContainerView.alpha = 1
                
                }, callbackError: { (error:String) in
                    let alert = UIAlertController(title: "ScreenOut", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alert:UIAlertAction) in
                        exit(0)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
            })
        })
        
        
        
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter code here"
        }
        
        alertController.addAction(saveAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("locationAuthorizationDidChange"), name: "AuthorizationDidChange", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func displayAllowAccessAlert(_: AnyObject!) {
        UserLocation.sharedInstance.requestAuthorizedWhenInUseAccess()
    }
    
    func locationAuthorizationDidChange() {
        switch (CLLocationManager.authorizationStatus()) {
        case .Authorized:
            openDashboardWithAnimation(false)
            
        case .AuthorizedWhenInUse:
            openDashboardWithAnimation(false)
            
        case .Denied:
            print("Denied")
            
        default:
            print("default")
        }
    }
    
    func openDashboardWithAnimation(animation: Bool) {
        let dashboardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DashboardViewController") as! DashboardViewController
        self.navigationController?.pushViewController(dashboardViewController, animated: true)
    }
}
