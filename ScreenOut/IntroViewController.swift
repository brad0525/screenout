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
    @IBOutlet weak var registrationTextField: UITextField!
    @IBOutlet weak var enterTextField: UIButton!
    
    internal let MAX_REGISTRATION_CODE = 7
    
    // MARK: View life circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDoneButtonOnKeyboard()
        
//        #if DEBUG
//            UserDefaultKey.apikey = "f01e119946e3cec8e08dcfbe11cf89d4"
//        #endif
        
        if (UserDefaultKey.apikey != nil) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.registerUAirshipAndPushNotification()
            openDashboardWithAnimation(false)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(locationAuthorizationDidChange), name: "AuthorizationDidChange", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Internal function
    
    func locationAuthorizationDidChange() {
        switch (CLLocationManager.authorizationStatus()) {
        case .Authorized:
            openDashboardWithAnimation(false)
            
        case .AuthorizedWhenInUse:
            openDashboardWithAnimation(false)
            
        case .Denied:
            showErrorAlertView("You have to enable location service to use the app.", viewcontroller: self)
            print("Denied")
            
        default:
            print("default")
        }
    }
    
    func openDashboardWithAnimation(animation: Bool) {
        let dashboardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SWRevealViewController") 
        self.navigationController?.pushViewController(dashboardViewController, animated: true)
        
        
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.BlackTranslucent
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        registrationTextField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction()
    {
        registrationTextField.resignFirstResponder()
    }
    
    // MARK: Actions
    
    @IBAction func displayAllowAccessAlert(_: AnyObject!) {
        UserLocation.sharedInstance.requestAuthorizedWhenInUseAccess()
    }
    
    @IBAction func enterButtonClicked(sender: AnyObject) {
        let code = registrationTextField.text!
        if code.characters.count == MAX_REGISTRATION_CODE {
            showProgressHUD(self)
            APIClient.sharedInstance.verifyUserCode(code, callbackSucceed: { (dic:NSDictionary) in
                hideProgressHUD(self)
                self.registrationTextField.resignFirstResponder()
                
                if let apikey = dic["apikey"] as? String {
                    UserDefaultKey.apikey = apikey
                }
            
                if CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
                    self.openDashboardWithAnimation(true)
                }
                else {
                    UserLocation.sharedInstance.requestAuthorizedWhenInUseAccess()
                }
                
                }, callbackError: { (error:String) in
                    hideProgressHUD(self)
                    showErrorAlertView(error, viewcontroller: self)
            })
        }
        else {
            showErrorAlertView("Enter the 7-digit registration code", viewcontroller: self)
        }
        
    }
    
}

extension IntroViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
