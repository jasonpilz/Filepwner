//
//  MasterViewController.swift
//  Filepwner
//
//  Created by Jason Pilz on 1/9/15.
//  Copyright (c) 2015 PilzArche. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, ModelDelegate, UITableViewDataSource {
    
    // MARK: - VC Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println("Called viewDidLoad() - MasterViewController")
        
        JMPMovieStore.sharedStore.delegate = self
        JMPMovieStore.sharedStore.loadRecords()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        self.navigationController?.toolbarHidden = false
        self.navigationController?.toolbar.barTintColor = UIColor.blackColor()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.translucent = true
        // This line informs Navigation Controller to set the status bar in white
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Black Theme
        self.tableView.separatorColor = UIColor.darkGrayColor()
        self.tableView.backgroundColor = UIColor.blackColor()
        
//        // Add background image
//        var magpulImage = UIImageView(image: UIImage(named: "GlockLogo.png"))
//        magpulImage.frame = self.tableView.bounds
//        
//        // Add Blur Effect on background image
//        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//        var blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = magpulImage.bounds
//        magpulImage.autoresizesSubviews = true
//        blurEffectView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
//        
//        // Add to view heirarchy
//        self.tableView.backgroundView = magpulImage
//        magpulImage.addSubview(blurEffectView)
        
        // Set up a refreshControl
        refreshControl = UIRefreshControl()
//        let attributedString = NSAttributedString(string: "Refreshing...", attributes: [NSForegroundColorAttributeName:UIColor.greenColor()])
//        refreshControl?.attributedTitle = attributedString
        refreshControl?.tintColor = UIColor.greenColor()
        refreshControl?.addTarget(self, action: "updateRecords", forControlEvents: .ValueChanged)
        
        //let float: CGFloat = 1
        // This line corrects hidden refreshControl issue (when background image and blur view used)
        //magpulImage.layer.zPosition -= 1
        
        let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        messageLabel.text = ("Loading Data...")
        messageLabel.textColor = UIColor.lightGrayColor()
        messageLabel.textAlignment = .Center
        messageLabel.numberOfLines = 1
        
        messageLabel.font = UIFont(name: "Helvetica Neue Thin", size: 20)
        messageLabel.sizeToFit()
        self.tableView.backgroundView = messageLabel
        self.tableView.separatorStyle = .None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let movie = JMPMovieStore.sharedStore.get(indexPath.row)
            (segue.destinationViewController as DetailViewController).detailItem = movie
                println("Transferring DetailItem: \(movie)")
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        println("Called numberOfSectionsInTableView")
        
        if JMPMovieStore.sharedStore.movies.isEmpty {
            return 0
        } else {
            self.tableView.separatorStyle = .SingleLine
            self.tableView.backgroundView = nil
            //self.tableView.backgroundColor = UIColor.whiteColor() // Delete for Black Theme
            
//            let magpulImage = UIImageView(image: UIImage(named: "GlockLogo.png"))
//            magpulImage.frame = self.tableView.bounds
//            self.tableView.backgroundView = magpulImage
//            // Blur Effect
//            var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//            var blurEffectView = UIVisualEffectView(effect: blurEffect)
//            blurEffectView.frame = self.tableView.bounds
//            magpulImage.addSubview(blurEffectView)
            
            return 1
        }
        
        //return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return JMPMovieStore.sharedStore.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let movie = JMPMovieStore.sharedStore.get(indexPath.row)
        cell.textLabel!.text = movie.title
        cell.textLabel!.textColor = UIColor.lightGrayColor() // Black Theme
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            JMPMovieStore.sharedStore.removeMovieAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - ModelDelegate
    
    func modelUpdated() {
        refreshControl?.endRefreshing()
        self.configureCounterLabel()
        
        if JMPMovieStore.sharedStore.movies.isEmpty {
            
            refreshControl?.hidden = true
            
            let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            messageLabel.text = ("No Movies in Database. \n Click + to add. \n Swipe down to Refresh.")
            messageLabel.textColor = UIColor.darkGrayColor()
            messageLabel.textAlignment = .Center
            messageLabel.numberOfLines = 3
            messageLabel.font = UIFont(name: "Helvetica Neue Thin", size: 20)
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            self.tableView.backgroundColor = UIColor.blackColor()
            self.tableView.separatorStyle = .None
            refreshControl?.endRefreshing()

        }
        tableView.reloadData()
    }
    
    // MARK: - Custom Methods
    
    func updateRecords() {
        JMPMovieStore.sharedStore.loadRecords()
    }

    func configureCounterLabel() {
        // Set up toolbar movie counter label
        var countLabel = UILabel(frame: CGRectMake(0, 0, 110, 44))
        let font = UIFont.systemFontOfSize(11)
        countLabel.textAlignment = .Center
        countLabel.textColor = UIColor.whiteColor()
        countLabel.font = font
        countLabel.backgroundColor = UIColor.clearColor()
        
        let countBbi = UIBarButtonItem(customView: countLabel)
        let flexibleBbi = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        self.toolbarItems = [flexibleBbi, countBbi, flexibleBbi]
        
        var total = JMPMovieStore.sharedStore.count
        var totalCount = ("\(total) Movies")
        countLabel.text = totalCount
    }


}

