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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
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
