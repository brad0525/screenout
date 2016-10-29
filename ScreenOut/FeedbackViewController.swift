//
//  FeedbackViewController.swift
//  ScreenOut
//
//  Created by Eric Rohlman on 12/17/14.
//  Copyright (c) 2014 Eric Rohlman. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var feedbackTextField:UITextField!
    @IBOutlet weak var feedbackButton:UIButton!
    
    // MARK: View life circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "Support"
        
        // navigation controller
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named: "close"), style:.Plain, target:self, action: #selector(closeButtonPressed))
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: IBActions
    
    @IBAction func sendButtonTapped(sender:AnyObject) {
        if nameTextField.hasText() == false {
            showErrorAlertView("Please input name field.", viewcontroller: self)
        }
        else if emailTextField.hasText() == false {
            showErrorAlertView("Please input email field.", viewcontroller: self)
        }
        else if emailTextField.hasText() == true && isValidEmail(emailTextField.text!) == false {
            showErrorAlertView("Email address is invalid.", viewcontroller: self)
        }
        else if feedbackTextField.hasText() == false {
            showErrorAlertView("Please input feedback field.", viewcontroller: self)
        }
        else {
            
            let email = self.emailTextField.text!
            let comments = self.feedbackTextField.text!
            let name = self.nameTextField.text!
            showProgressHUD(self)
            APIClient.sharedInstance.comments(name, email: email, comments: comments, callbackSucceed: { (dic:NSDictionary) in
                hideProgressHUD(self)
                showAlertView("Email sent successfully!", viewcontroller: self, completionHandler: { 
                    self.handleSuccess()
                })
            }) { (error:String) in
                hideProgressHUD(self)
                showErrorAlertView(error, viewcontroller: self)
            }
        }
    }

    @IBAction func nameViewClicked(sender: AnyObject) {
        nameTextField.becomeFirstResponder()
    }
    @IBAction func emailViewClicked(sender: AnyObject) {
        emailTextField.becomeFirstResponder()
    }
    
    // MARK: Internal func
    
    internal func closeButtonPressed() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    internal func handleSuccess() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    internal func handleFeedbackError(error:String) {
        self.feedbackButton.enabled = true
        
        let alert = UIAlertView(title: "Message failed", message: error, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    internal func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    // MARK: TextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "What can we help you with" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "What can we help you with"
        }
    }
}

extension FeedbackViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
