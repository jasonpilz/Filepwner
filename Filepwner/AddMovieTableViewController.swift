//
//  AddMovieTableViewController.swift
//  Filepwner
//
//  Created by Jason Pilz on 1/12/15.
//  Copyright (c) 2015 PilzArche. All rights reserved.
//

import UIKit

class AddMovieTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var seriesTitleField: UITextField!
    @IBOutlet weak var primaryDriveField: UITextField!
    @IBOutlet weak var backupDriveField: UITextField!
    @IBOutlet weak var opticalField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var sizeField: UITextField!
    
    @IBOutlet weak var hdSwitch: UISwitch!
    @IBOutlet weak var watchedSwitch: UISwitch!
    @IBOutlet weak var wishListSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        tableView.keyboardDismissMode = .Interactive
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.titleField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "dismissAndSave" {
            let movie = JMPMovie(title: titleField.text!,
                seriesTitle: seriesTitleField.text!,
                primaryDrive: primaryDriveField.text!,
                backupDrive: backupDriveField.text!,
                optical: opticalField.text!,
                type: typeField.text!,
                size: (sizeField.text as NSString!).doubleValue,
                wishlist: wishListSwitch.on,
                watched: watchedSwitch.on,
                hd: hdSwitch.on)
            
            // Local Storage (non-persisting)
            //JMPMovieStore.sharedStore.add(movie)
            
            // CloudKit Storage
            JMPMovieStore.sharedStore.saveRecord(movie)
            
        } else if segue.identifier == "showPrimaryDrive" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! PrimaryDrive
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.navigationItem.hidesBackButton = false
        }
    }
    
    
    
    
    
    
    
    

}
