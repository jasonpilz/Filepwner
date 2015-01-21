//
//  AddMovieTableViewController.swift
//  Filepwner
//
//  Created by Jason Pilz on 1/12/15.
//  Copyright (c) 2015 PilzArche. All rights reserved.
//

import UIKit

class AddMovieTableViewController: UITableViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var primaryDriveField: UITextField!
    @IBOutlet weak var backupDriveField: UITextField!
    @IBOutlet weak var opticalField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var hdSwitch: UISwitch!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make Navigation bar completely Transparent
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.translucent = true
        
        //self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        //self.navigationController?.navigationBar.titleTextAttributes =

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "dismissAndSave" {
            let movie = JMPMovie(title: titleField.text,
                primaryDrive: primaryDriveField.text,
                backupDrive: backupDriveField.text,
                optical: opticalField.text,
                type: typeField.text,
                hd: hdSwitch.on)
            
            // Local Storage (non-persisting)
            //JMPMovieStore.sharedStore.add(movie)
            
            // CloudKit Storage
            JMPMovieStore.sharedStore.saveRecord(movie)
            
        }
    }
    
    
    
    
    
    

}
