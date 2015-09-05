//
//  MasterViewController.swift
//  Filepwner
//
//  Created by Jason Pilz on 1/9/15.
//  Copyright (c) 2015 PilzArche. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, ModelDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    // MARK: - Properties
    
    let model: JMPMovieStore = JMPMovieStore.sharedStore
    var detailViewController: DetailViewController? = nil
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    var filteredMovies = [JMPMovie]()
    var totalGB: Double {
        var total: Double = 0.0
        if self.searchController.active {
            for movie in self.filteredMovies {
                if let size = movie.size {
                    total += size
                }
            }
        } else {
            for movie in JMPMovieStore.sharedStore.movies {
                if let size = movie.size {
                    total += size
                }
            }
        }
        return total
    }
    
    // MARK: - VC Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        super.viewDidLoad()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        model.delegate = self
        
        if model.movies.isEmpty {
            model.loadRecords()
            model.checkSubscriptions()
            model.registerSubscription()
        }
        
        //model.deleteSubscriptions()
        
        // Navigation Controller Appearance
        self.navigationController?.toolbarHidden = false
        
        self.navigationController?.toolbar.barTintColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        
        // Gold BBI/Nav Item Theme
        UINavigationBar.appearance().tintColor = UIColor(red: 255.0/255.0, green: 215.0/255.0, blue: 0.0/0.0, alpha: 0.9)
        
        self.navigationController?.navigationBar.translucent = true
        // This line informs Navigation Controller to set the status bar in white
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // TableView Appearance
        self.tableView.indicatorStyle = .White
        self.tableView.backgroundColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1.0)
        
        self.tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        self.tableView.sectionIndexColor = UIColor(red: 255.0/255.0, green: 215.0/255.0, blue: 0.0/0.0, alpha: 0.9)
        
        // UISearchController Setup
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        self.definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchBar.delegate = self
        // First size the searchBar...
        searchController.searchBar.sizeToFit()
        // Then add to the view heirarchy.
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.keyboardAppearance = .Dark
        searchController.searchBar.barStyle = .Black
        
        //Set up a refreshControl
        //refreshControl = UIRefreshControl()
        //refreshControl?.tintColor = UIColor.lightGrayColor()
        //refreshControl?.addTarget(self, action: "updateRecords", forControlEvents: .ValueChanged)
        
        // Tableview "Loading Data..." background
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
    
    override func viewWillAppear(animated: Bool) {
        self.configureCounterLabel()
        
        // Used to correct issue of tableviewcell not deselecting.
        if tableView.indexPathForSelectedRow() != nil {
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow()!, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
            if (self.searchController.active) {
                let indexPath = self.tableView.indexPathForSelectedRow()!
                let movie = self.filteredMovies[indexPath.row]
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = movie
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            } else {
                
                let indexPath = self.tableView.indexPathForSelectedRow()!
                let movie = JMPMovieStore.sharedStore.get(indexPath.row)
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = movie
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    @IBAction func unwindToMasterVC(segue: UIStoryboardSegue) {
        println("unwindSegue Activated!")
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if JMPMovieStore.sharedStore.movies.isEmpty {
            return 0
        } else {
            self.tableView.separatorStyle = .SingleLine
            self.tableView.backgroundView = nil
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.searchController.active { //tableView == self.searchDisplayController!.searchResultsTableView {
            return nil
        } else if section == 0 {
            return "0"
        }
        return nil
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        // Used to populate tableview Index
        
//        let array: Array = ["0"]
//        return array
        return nil
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.active { //tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredMovies.count
        } else {
            return JMPMovieStore.sharedStore.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        // This block used for Search Display Controller feature...
        var movie: JMPMovie
        // Check to see whether the normal table or the Search results table is being displayed, and set the JMPMovie object from the appropriate array
        if self.searchController.active { // == true && self.filteredMovies.count != 0 { //tableView == self.searchDisplayController!.searchResultsTableView {
            movie = filteredMovies[indexPath.row]
            cell.accessoryType = .DisclosureIndicator
        } else {
            movie = JMPMovieStore.sharedStore.get(indexPath.row)
            cell.accessoryType = .None
        }
        
        cell.textLabel!.text = movie.title
        cell.backgroundColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 23/255)
        
        // Adjust Cell selected color
        let colorView = UIView()
        colorView.backgroundColor = UIColor(red: 0.32, green: 0.32, blue: 0.32, alpha: 1.0)
        cell.selectedBackgroundView = colorView
        
        if (movie.seriesTitle != nil) {
            cell.detailTextLabel!.text = movie.seriesTitle
            // These lines add the detailTextLabel back into the view heirarchy...
            cell.detailTextLabel!.sizeToFit()
            // Position the detailTextLabel...
            cell.layoutSubviews()
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
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
        //refreshControl?.endRefreshing()
        
        if JMPMovieStore.sharedStore.movies.isEmpty {
            //refreshControl?.hidden = true
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
        }
        tableView.reloadData()
        self.configureCounterLabel()
    }
        
    func updateInterfaceForNetworkIssue() {
        //self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Search Controller Delegate
    
    func willPresentSearchController(searchController: UISearchController) {
        self.tableView.backgroundColor = UIColor.blackColor()
        self.tableView.separatorColor = UIColor.darkGrayColor()
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        // Undo appearance adjustments from willPresentSearchController
        self.tableView.backgroundColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1.0)
        self.tableView.separatorColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1.0)
    }
    
    // MARK: - Search Results Updating Delegate
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filterContentForSearchText(self.searchController.searchBar.text)
        configureCounterLabel()
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(searchText: String) {
        
        if searchText == "" {
            
            // If empty the search results are the same as the original data
            self.filteredMovies = JMPMovieStore.sharedStore.movies
        } else {
            // Filter the array using the Swift Array filter method
            let movies = JMPMovieStore.sharedStore.movies
            self.filteredMovies = movies.filter({(movie: JMPMovie) -> Bool in
                let titleStringMatch = movie.title.lowercaseString.rangeOfString(searchText.lowercaseString)
                let seriesTitleStringMatch = movie.seriesTitle?.lowercaseString.rangeOfString(searchText.lowercaseString)
                return (titleStringMatch != nil) || (seriesTitleStringMatch != nil)
            })
        }
    }
    
    // MARK: - Custom Methods
    
    func updateRecords() {
        self.tableView.backgroundView = nil
        JMPMovieStore.sharedStore.loadRecords()
    }
    
    func configureCounterLabel() {
        
        var totalMovies: Int
        
        if (self.searchController.active) {
            totalMovies = filteredMovies.count
        } else {
            totalMovies = JMPMovieStore.sharedStore.movies.count
        }
        
        var infoLabel = UILabel(frame: CGRectMake(0, 0, 110, 44))
        infoLabel.textAlignment = .Center
        infoLabel.backgroundColor = UIColor.clearColor()
        infoLabel.font = UIFont.systemFontOfSize(11)
        infoLabel.textColor = UIColor.whiteColor()
        infoLabel.numberOfLines = 0
        
        if totalGB > 999.9 {
            let totalTB = totalGB / 1000
            infoLabel.text = ("\(totalMovies) Movies\n") + (NSString(format: "%.3f TB", totalTB) as String)
        } else {
            infoLabel.text = ("\(totalMovies) Movies\n") + (NSString(format: "%.3f GB", totalGB) as String)
        }
        
        let infoBBI = UIBarButtonItem(customView: infoLabel)
        let flexibleBBI = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        self.toolbarItems = [flexibleBBI, infoBBI, flexibleBBI]
    }
        


    
    
    
    
    
    
    
    
    
    
}

