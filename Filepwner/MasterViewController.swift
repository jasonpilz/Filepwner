//
//  MasterViewController.swift
//  Filepwner
//
//  Created by Jason Pilz on 1/9/15.
//  Copyright (c) 2015 PilzArche. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, ModelDelegate {


    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        JMPMovieStore.sharedStore.delegate = self
        JMPMovieStore.sharedStore.loadRecords()
        
        // Set up a refreshControl
        refreshControl = UIRefreshControl()
        let attributedString = NSAttributedString(string: "Refreshing...")
        refreshControl?.attributedTitle = attributedString
        refreshControl?.addTarget(self, action: "updateRecords", forControlEvents: .ValueChanged)
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationController?.toolbarHidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureCounterLabel() {
        // Set up toolbar movie counter label
        var countLabel = UILabel(frame: CGRectMake(0, 0, 110, 44))
        let font = UIFont.systemFontOfSize(11)
        countLabel.textAlignment = .Center
        countLabel.textColor = UIColor.blackColor()
        countLabel.font = font
        countLabel.backgroundColor = UIColor.clearColor()
        
        let countBbi = UIBarButtonItem(customView: countLabel)
        let flexibleBbi = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        self.toolbarItems = [flexibleBbi, countBbi, flexibleBbi]
        
        var total = JMPMovieStore.sharedStore.count
        var totalCount = ("\(total) Movies")
        countLabel.text = totalCount
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return JMPMovieStore.sharedStore.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let movie = JMPMovieStore.sharedStore.get(indexPath.row)
        cell.textLabel!.text = movie.title
        
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
    
    func updateRecords() {
        JMPMovieStore.sharedStore.loadRecords()
    }
    
    // MARK: - ModelDelegate
    
    func modelUpdated() {
        refreshControl?.endRefreshing()
        self.configureCounterLabel()
        tableView.reloadData()
    }
    


}

