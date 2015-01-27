//
//  DetailViewController.swift
//  Filepwner
//
//  Created by Jason Pilz on 1/9/15.
//  Copyright (c) 2015 PilzArche. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hdLabel: UILabel!
    @IBOutlet weak var primaryDriveLabel: UILabel!
    @IBOutlet weak var backupDriveLabel: UILabel!
    @IBOutlet weak var opticalLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!

    var detailItem: JMPMovie? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Movie"
        println("My detail item is: \(self.detailItem)")
        self.configureView()
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let movie: JMPMovie = self.detailItem {
            if let titleLabel = self.titleLabel {
                titleLabel.text = movie.title
            }
            if let type = self.typeLabel {
                type.text = movie.type
            }
            if let hdLabel = self.hdLabel {
                if movie.hd == true {
                    self.hdLabel.text = "HD"
                } else {
                    self.hdLabel.text = "SD"
                    self.hdLabel.textColor = UIColor.lightGrayColor()
                }
            }
            if let primaryLabel = self.primaryDriveLabel {
                primaryLabel.text = movie.primaryDrive
            }
            if let backup = self.backupDriveLabel {
                backup.text = movie.backupDrive
            }
            if let optical = self.opticalLabel {
                optical.text = movie.optical
            }
        }
    }

    @IBAction func deleteMovie(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let alertDeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (ACTION :UIAlertAction!) in
            JMPMovieStore.sharedStore.deleteRecord(self.detailItem!)
            self.navigationController?.popViewControllerAnimated(true)
            })
        alert.addAction(alertCancelAction)
        alert.addAction(alertDeleteAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

