//
//  FeedbackViewController.swift
//  ScreenOut
//
//  Created by Eric Rohlman on 12/17/14.
//  Copyright (c) 2014 Eric Rohlman. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var feedbackTextView:UITextView!
    @IBOutlet weak var feedbackButton:UIButton!
    @IBOutlet weak var cancelButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func sendButtonTapped(sender:AnyObject) {
        if (self.emailTextField.hasText() && self.feedbackTextView.hasText()) {
            
            if self.isValidEmail(self.emailTextField.text!) {
                self.feedbackButton.enabled = false
                self.cancelButton.enabled = false
                
                self.sendFeedback()
            }
        }
    }

    @IBAction func cancelButtonTapped(sender:AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    internal func handleSuccess() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    internal func handleFeedbackError(error:String) {
        self.feedbackButton.enabled = true
        self.cancelButton.enabled = true
        
        let alert = UIAlertView(title: "Message failed", message: error, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    internal func isValidEmail(email:String) -> Bool {
        
        let arr = email.componentsSeparatedByString("@")
        if arr.count == 2 {
            return true
        }
        
        return false
    }
    
    internal func sendFeedback() {
        let email = self.emailTextField.text!
        let comments = self.feedbackTextView.text!
        APIClient.sharedInstance.comments(email, comments: comments, callbackSucceed: { (dic:NSDictionary) in
            self.handleSuccess()
        }) { (error:String) in
            self.handleFeedbackError(error)
        }
        
        /*
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        var queryString = "id=\(Device().uuid)&email=\(self.emailTextField.text)&msg=\(self.feedbackTextView.text)"
        var escapedString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        var urlString = "\(Network().url)/messages.php?" + escapedString!
        
        let task = Network().session!.dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    self.handleSuccess()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    self.handleFeedbackError(error!)
                })
            }
        })
        task.resume()
         */
    }
    
    // MARK: TextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Feedback" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "Feedback"
        }
    }
}
