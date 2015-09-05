//
//  JMPMovieStore.swift
//  Filepwner
//
//  Created by Jason Pilz on 1/13/15.
//  Copyright (c) 2015 PilzArche. All rights reserved.
//

import UIKit
import CloudKit
import Foundation

protocol ModelDelegate {
    func modelUpdated()
    func updateInterfaceForNetworkIssue()
}

class JMPMovieStore {
    
    // MARK: - Properties
    
    class var sharedStore: JMPMovieStore {
        struct Static {
            static let instance = JMPMovieStore()
        }
        return Static.instance
    }
    var delegate: ModelDelegate?
    var movies: [JMPMovie] = []
    var count: Int {
        return movies.count
    }
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    // MARK: - Initializer
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    // MARK: - Functions
    
    func add(movie: JMPMovie) {
        movies.append(movie)
    }
    
    func replace(movie: JMPMovie, atIndex index: Int) {
        movies[index] = movie
    }
    
    func get(index: Int) -> JMPMovie {
        return movies[index]
    }
    
    func removeMovieAtIndex(index: Int) {
        let movie = JMPMovieStore.sharedStore.get(index)
        movies.removeAtIndex(index)
        JMPMovieStore.sharedStore.deleteRecord(movie)
    }
    
    func notifyUser(title: String, message: String) -> Void {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    // MARK: - CloudKit
    
    func saveRecord(movie: JMPMovie) {
        
        let myRecord = CKRecord(recordType: "Movie")
        myRecord.setObject(movie.title, forKey: "title")
        myRecord.setObject(movie.seriesTitle, forKey: "seriesTitle")
        myRecord.setObject(movie.primaryDrive, forKey: "primaryDrive")
        myRecord.setObject(movie.backupDrive, forKey: "backupDrive")
        myRecord.setObject(movie.optical, forKey: "optical")
        myRecord.setObject(movie.type, forKey: "type")
        myRecord.setObject(movie.size, forKey: "size")
        myRecord.setObject(movie.wishList, forKey: "wishList")
        myRecord.setObject(movie.watched, forKey: "watched")
        myRecord.setObject(movie.hd, forKey: "hd")
        myRecord.setObject(movie.dateCreated, forKey: "dateCreated")
        
        publicDB.saveRecord(myRecord, completionHandler: ({returnRecord, error in
            if let err = error {
                self.notifyUser("Save error", message: err.localizedDescription)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    println("Record saved successfully")
                    self.notifyUser("Success", message: "Movie saved successfully")
                }
            }
        }))
    }
    
    func deleteRecord(movie: JMPMovie) {
        println("Called JMPMovieStore deleteRecord:")
        
        // Remove the record from the public Database
        if let record = movie.record {
            publicDB.deleteRecordWithID(record.recordID, completionHandler: ({returnRecord, error in
                if let err = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.notifyUser("Delete Error", message: err.localizedDescription)
                    }
                } else {
                    println("Deleted Record sucessfully")
                    
                    // Remove the record from the local 'movies' array
                    if let index = find(self.movies, movie) {
                        self.movies.removeAtIndex(index)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.notifyUser("Success", message: "Record deleted successfully")
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                }
            }))
        } else {
            notifyUser("No record selected", message: "Use Query to select record to delete")
        }
    }
    
    
    func loadRecords() {
        self.movies.removeAll(keepCapacity: true)
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Movie", predicate: predicate)
        
        // Sort alphabetically.
        let sortTitle = NSSortDescriptor(key: "title", ascending: true)
        
        // Then sort by Date Created.
        let sortDateCreated = NSSortDescriptor(key: "dateCreated", ascending: true)
        
        // Add NSSortDescriptors as an array to the query sortDescriptors property.
        query.sortDescriptors = [sortTitle, sortDateCreated]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.recordFetchedBlock = recordFetchBlock
        queryOperation.queryCompletionBlock = queryCompletionBlock
        
        publicDB.addOperation(queryOperation)
    }
    
    // MARK: - Blocks
    
    func recordFetchBlock(record: CKRecord!) {
        // Add to JMPMoviestore Movies array
        let movie = JMPMovie(record: record as CKRecord, database: self.publicDB)
        self.movies.append(movie)
        
        //println("Added a record to movies")
        //let moviesCount = JMPMovieStore.sharedStore.count
        //println("\(moviesCount) movies in the movieStore")
        
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.modelUpdated()
        }
        
    }
    
    func queryCompletionBlock(cursor: CKQueryCursor!, error: NSError!) {
        if error != nil {
            dispatch_async(dispatch_get_main_queue()) {
                self.notifyUser("Cloud access error", message: error.localizedDescription)
                self.delegate?.updateInterfaceForNetworkIssue()
            }
        } else if cursor != nil {
            //println("Got Cursor!")
            
            let cursorQuery = CKQueryOperation(cursor: cursor)
            cursorQuery.recordFetchedBlock = self.recordFetchBlock
            cursorQuery.queryCompletionBlock = self.queryCompletionBlock
            self.publicDB.addOperation(cursorQuery)
        }
    }
    
    // MARK: - Subscription
    
    func registerSubscription() {
        
        //let truePredicate = NSPredicate(value: true)
        
        let predicate = NSPredicate(format: "title != %@", "")
        
        let subscription = CKSubscription(recordType: "Movie", predicate: predicate, options: .FiresOnRecordCreation)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "A new movie was added"
        notificationInfo.shouldBadge = true
        //notificationInfo.desiredKeys = ["title"]
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.saveSubscription(subscription, completionHandler: ({returnRecord, error in
            if let err = error {
                println("Subscription failed %@", err.localizedDescription)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.notifyUser("Success", message: "Subscription set up successfully")
                }
            }
        }))
    }
    
    func fetchRecord(recordID: CKRecordID) {
        publicDB.fetchRecordWithID(recordID, completionHandler: ({record, error in
            if let err = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.notifyUser("Fetch error", message: err.localizedDescription)
                }
            } else {
                
                println("Fetched a record")
                let movie = JMPMovie(record: record, database: self.publicDB)
                self.movies.append(movie)
                
                // RE-SORT Movies ARRAY
                // Sort alphabetically
                let sortTitle = NSSortDescriptor(key: "title", ascending: true)
                // Then sort by Date Created
                let sortDateCreated = NSSortDescriptor(key: "dateCreated", ascending: true)
                let sortDescriptors = [sortTitle, sortDateCreated]
                
                // TO-DO
                // Replace Movies array with re-sorted objects
                
                println("Added a record to movies")
                let moviesCount = JMPMovieStore.sharedStore.count
                println("\(moviesCount) movies in the movieStore")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                    println()
                }
            }
        }))
    }
    
    // iOS 8.3 bug - Internal server error.
    func resetBadgeCounter() {
        let badgeResetOperation = CKModifyBadgeOperation(badgeValue: 0)
        badgeResetOperation.modifyBadgeCompletionBlock = {(error) -> Void in
            if error != nil {
                println("Error resetting badge: \(error)")
            } else {
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
        }
        container.addOperation(badgeResetOperation)
    }
    
    func checkSubscriptions() {
        publicDB.fetchAllSubscriptionsWithCompletionHandler ({subscriptions, error in
            var subscriptionIDs: [String] = []
            for subscriptionObject in subscriptions {
                var subscription: CKSubscription = subscriptionObject as! CKSubscription
                subscriptionIDs.append(subscription.subscriptionID)
                println("Checked one subscription - \(subscription)")
            }
        })
    }
    
    func deleteSubscriptions() {
        publicDB.fetchAllSubscriptionsWithCompletionHandler ({subscriptions, error in
            for subscriptionObject in subscriptions {
                var subscription: CKSubscription = subscriptionObject as! CKSubscription
                self.publicDB.deleteSubscriptionWithID(subscription.subscriptionID, completionHandler: ({ ID, error in
                    
                    println("DeletedSubscriptionWithID")
                }))
            }
        })
    }
    
    
    
    
    
    
}

