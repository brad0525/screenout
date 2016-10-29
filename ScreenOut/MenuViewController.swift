//
//  MenuViewController.swift
//  ScreenOut
//
//  Created by Hoang on 10/28/16.
//  Copyright © 2016 Eric Rohlman. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate {
    func didClickHomeButon()
    func didClickNotificationButton()
    func didClickSupportButton()
    func didClickSetLocationButton()
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var locationButton: UIButton!
    
    var delegate : MenuViewControllerDelegate!
    var numberOfUnreadNotification : Int = 0
    
    enum CellContentTagEnum: Int {
        case imageView = 1, content, notificationNumber
    }
    
    enum RowEnum: Int {
        case home = 0, notifications, support
    }
    
    internal let contents : [String] = ["Home", "Notifications", "Support"]
    internal let images : [String] = ["home", "notification", "support"]

    
    // MARK: View life circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        menuTableView.reloadData()
    }
    
    // MARK: IBActions

    @IBAction func locationButtonClicked(sender: AnyObject) {
        delegate.didClickSetLocationButton()
    }
}

extension MenuViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuTableViewCell")!
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        let imageView = cell.viewWithTag(CellContentTagEnum.imageView.rawValue) as! UIImageView
        imageView.image = UIImage(named: images[indexPath.row])
        
        let contentLabel = cell.viewWithTag(CellContentTagEnum.content.rawValue) as! UILabel
        contentLabel.text = contents[indexPath.row]
        
        let notificationNumberButton = cell.viewWithTag(CellContentTagEnum.notificationNumber.rawValue) as! UIButton
        if indexPath.row == RowEnum.notifications.rawValue {
            if numberOfUnreadNotification > 0 {
                notificationNumberButton.hidden = false
                notificationNumberButton.setTitle("\(numberOfUnreadNotification)", forState: .Normal)
            }
            else {
                notificationNumberButton.hidden = true
            }
        }
        else {
            notificationNumberButton.hidden = true
        }
        
        return cell
    }
}

extension MenuViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case RowEnum.home.rawValue:
            delegate.didClickHomeButon()
            
        case RowEnum.notifications.rawValue:
            delegate.didClickNotificationButton()
            
        case RowEnum.support.rawValue:
            delegate.didClickSupportButton()
            
        default:
            break;
        }
    }
}
