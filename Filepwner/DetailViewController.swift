//
//  DetailViewController.swift
//  Filepwner
//
//  Created by Jason Pilz on 1/9/15.
//  Copyright (c) 2015 PilzArche. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController, UITableViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seriesTitleLabel: UILabel!
    
    @IBOutlet weak var hdLabel: UILabel!
    @IBOutlet weak var primaryDriveLabel: UILabel!
    @IBOutlet weak var backupDriveLabel: UILabel!
    @IBOutlet weak var opticalLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!

    var detailItem: JMPMovie? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = ""
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.32, green: 0.32, blue: 0.32, alpha: 1.0)
        self.navigationController?.toolbar.barTintColor = UIColor(red: 0.32, green: 0.32, blue: 0.32, alpha: 1.0)
        
        if self.detailItem == nil {
            
            var placeholderView = UIView(frame: self.tableView.frame)
            placeholderView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
            placeholderView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            self.tableView.addSubview(placeholderView)
            
            let logoImageView = UIImageView(image: UIImage(named: "fplogov2.png"))
            logoImageView.contentMode = .ScaleAspectFit
            logoImageView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleWidth
            
            logoImageView.frame.size.width = 650
            logoImageView.frame.size.height = 110

            let w: CGFloat = (self.view.bounds.size.width / 2) - (logoImageView.bounds.size.width / 2)
            let h: CGFloat = (self.view.bounds.size.height / 2) - (logoImageView.frame.size.height)
            logoImageView.frame.origin.x = w
            logoImageView.frame.origin.y = h

            placeholderView.addSubview(logoImageView)
            
            // Disable tableview scroll
            self.tableView.scrollEnabled = false
            
            // Hide the "Edit" BarButtonItem
            self.navigationItem.rightBarButtonItem?.enabled = false
        }

        println("My detail item is: \(self.detailItem)")
        self.configureView()
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var string: String?
        if self.detailItem == nil {
            string = nil
        } else if section == 0 {
            string == nil
        } else if section == 1 {
            string = "Storage"
        } else if section == 2 {
            string = "File Info"
        } else if section == 3 {
            string = nil
        }
        return string
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            cell.backgroundColor = UIColor.clearColor()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let movie: JMPMovie = self.detailItem {
            if let titleLabel = self.titleLabel {
                titleLabel.text = movie.title
            }
            if let series = self.seriesTitleLabel {
                series.text = movie.seriesTitle
            }
            if let type = self.typeLabel {
                type.text = movie.type
            }
            if let size = self.sizeLabel {
                if movie.size > 0 {
                    sizeLabel.text = (movie.size!.description) + (" GB")
                } else if movie.size == 0 {
                    sizeLabel.text = ""
                }
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
            
            // Set up a date label in the toolbar
            var dateLabel = UILabel(frame: CGRectMake(0, 0, 270, 44))
            dateLabel.textAlignment = .Center
            dateLabel.backgroundColor = UIColor.clearColor()
            dateLabel.font = UIFont.systemFontOfSize(11)
            dateLabel.textColor = UIColor.whiteColor()
            dateLabel.numberOfLines = 1
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .ShortStyle
            
            let dateString = formatter.stringFromDate(movie.dateCreated!)
            dateLabel.text = "Created: " + dateString
            
            let infoBBI = UIBarButtonItem(customView: dateLabel)
            let flexibleBBI = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            self.toolbarItems = [flexibleBBI, infoBBI, flexibleBBI]
        }
    }

    @IBAction func deleteMovie(sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let alertDeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (ACTION :UIAlertAction!) in
            JMPMovieStore.sharedStore.deleteRecord(self.detailItem!)
            self.performSegueWithIdentifier("unwindSegue", sender: self)
            })
        
        alert.addAction(alertCancelAction)
        alert.addAction(alertDeleteAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

