//
//  TableViewController.swift
//  SSLocalNotification
//
//  Created by Nicholas Bellucci on 4/4/17.
//  Copyright © 2017 Nicholas Bellucci. All rights reserved.
//

import UIKit
import SSLocalNotification

class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SSLocalNotification"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath)
        cell.textLabel?.textColor = .blue
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Notification without expansion ability"
        case 1:
            cell.textLabel?.text = "Notification with expansion ability"
        case 2:
            cell.textLabel?.text = "Notification with notification actions"
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification: SSLocalNotificationController?
        
        switch indexPath.row {
        case 0:
            notification = SSLocalNotificationController(title: "SSLocalNotification", message: "This is a test notification!", preferredStyle: .light)
            notification?.setTitleFont(fontName: "Avenir-Medium", color: .black)
            notification?.setMessageFont(fontName: "Avenir-Book", color: .black)
            notification?.presentLocalNotification()
        case 1:
            notification = SSLocalNotificationController(title: "SSLocalNotification", message: "This is a test notification! These may be longer than normal.", preferredStyle: .light)
            notification?.expandable = true
            notification?.setTitleFont(fontName: "Avenir-Medium", color: .black)
            notification?.setMessageFont(fontName: "Avenir-Book", color: .black)
            notification?.presentLocalNotification()
        case 2:
            notification = SSLocalNotificationController(title: "SSLocalNotification", message: "This is a test notification! Has this project helped you?", preferredStyle: .light)
            notification?.expandable = true
            
            notification?.addAction(action: SSLocalNotificationAction(title: "Yes it has!", fontName: "Avenir-Book", tint: .blue, handler: {
                print("Awesome!!!")
            }))
            notification?.addAction(action: SSLocalNotificationAction(title: "Not at all.", fontName: "Avenir-Book", tint: .blue, handler: {
                print("Sorry to hear that. Please let me know how I can improve it.")
            }))
            
            notification?.setTitleFont(fontName: "Avenir-Medium", color: .black)
            notification?.setMessageFont(fontName: "Avenir-Book", color: .black)
            notification?.presentLocalNotification()
        default:
            break
        }
    }
    
}
