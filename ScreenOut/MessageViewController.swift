//
//  MessageViewController.swift
//  ScreenOut
//
//  Created by Hoang on 4/4/16.
//  Copyright © 2016 Eric Rohlman. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    @IBOutlet weak var messageTableView: UITableView!
    var messages : Array = Array<NSDictionary>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Message"
        messageTableView.rowHeight = UITableViewAutomaticDimension;
        messageTableView.estimatedRowHeight = 44.0;
        getMessage()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    // MARK: - Methods
    
    func getMessage(){
        var deviceToken = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultKey.kDeviceToken) as? String
        //deviceToken = "9797A63844E6303804C934684AC8A6835F1321D0DD52640CECAC460F08FE0B9B"
        if deviceToken == nil {
            deviceToken = ""
        }
        showProgressHUD(self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let queryString = "requestType=getMessages&deviceToken=\(deviceToken!)"
        let escapedString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let urlString = "\(Network().url)/notes.php?" + escapedString!
        let task = Network().session!.dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (error == nil) {
                    let jsonObject: NSDictionary?
                    do {
                        jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary
                    }  catch {
                        fatalError()
                    }
                    print(jsonObject)
                    if let _ = jsonObject {
                        if let data = jsonObject?.valueForKey("data") {
                            let result = data.valueForKey("result") as? String
                            if result == "error" {
                                showAlertView(data.valueForKey("message") as! String, viewcontroller: self)
                            } else {
                                if let tempMessages = data.valueForKey("message") as? Array<NSDictionary> {
                                    self.messages = tempMessages
                                }
                            }
                        }
                    }
                } else {
                    showAlertView(error!.localizedDescription, viewcontroller: self)
                }
                var unreadCount : Int = 0
                for dic in self.messages {
                    if dic["isRead"] as? String == "no" {
                        unreadCount += 1
                    }
                }
                UIApplication.sharedApplication().applicationIconBadgeNumber = unreadCount
                self.messageTableView.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                hideProgressHUD(self)
            })
        })
        task.resume()
    }
    
    func updateMessage(isRead:String, messageID:String, completionHandler:(success: Bool, error:NSError?) -> Void){
        showProgressHUD(self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let queryString = "requestType=readNotification&isRead=\(isRead)&messageId=\(messageID)"
        let escapedString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let urlString = "\(Network().url)/notes.php?" + escapedString!
        let task = Network().session!.dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (error == nil) {
                    let jsonObject: NSDictionary?
                    do {
                        jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary
                    }  catch {
                        fatalError()
                    }
                    if let _ = jsonObject {
                        if let data = jsonObject?.valueForKey("data") {
                            if let result = data.valueForKey("result") as? String {
                                if result == "success" {
                                    completionHandler(success: true, error: nil)
                                }
                            }
                        }
                    }
                } else {
                    completionHandler(success: false, error: error)
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                hideProgressHUD(self)
            })
        })
        task.resume()
    }
    
    // MARK: - UITableView data source, delegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let reuseIdentifier = "MessageTableViewCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! MGSwipeTableCell!
        if cell == nil
        {
            cell = MGSwipeTableCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        }
        cell.delegate = self
        
        let dic = messages[indexPath.row]
        cell.textLabel?.text = dic.valueForKey("notification") as? String
        if dic["isRead"] as? String == "yes" {
            cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
        } else {
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(14.0)
        }
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor.redColor())
            ,MGSwipeButton(title: "Unread",backgroundColor: UIColor.lightGrayColor())]
        cell.rightSwipeSettings.transition = MGSwipeTransition.Rotate3D

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let isRead = "yes"
        updateMessageLocal(isRead, indexPath: indexPath)
    }
    
    func updateMessageLocal(flag:String, indexPath:NSIndexPath){
        let dic = messages[indexPath.row]
        let messageID = dic["id"] as! String
        let isRead = flag
        
        updateMessage(isRead, messageID: messageID) { (success:Bool, error:NSError?) in
            if success == true {
                self.getMessage()
            } else {
                showAlertView(error!.localizedDescription, viewcontroller: self)
            }
        }
    }

}

// MARK: - MGSwipeTableCellDelegate

extension MessageViewController: MGSwipeTableCellDelegate {
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let indexPath = messageTableView.indexPathForCell(cell)!
        var isRead:String!
        // 0 : delete
        // 1 : unread
        if index == 0  {
            isRead = "deleted"
        } else {
            isRead = "no"
        }
        updateMessageLocal(isRead, indexPath: indexPath)
        return true
    }
}
