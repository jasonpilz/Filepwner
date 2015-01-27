//
//  JMPMovieStore.swift
//  Filepwner
//
//  Created by Jason Pilz on 1/13/15.
//  Copyright (c) 2015 PilzArche. All rights reserved.
//

import UIKit
import CloudKit

protocol ModelDelegate {
    func modelUpdated()
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
    
    func get(index: Int) ->JMPMovie {
        return movies[index]
    }
    
    func removeMovieAtIndex(index: Int) {
        let movie = JMPMovieStore.sharedStore.get(index)
        movies.removeAtIndex(index)
        JMPMovieStore.sharedStore.deleteRecord(movie)
        
    }
    
    func notifyUser(title: String, message: String) ->Void {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }

    
    // MARK: - CloudKit
    
    func saveRecord(movie: JMPMovie) {
        let myRecord = CKRecord(recordType: "Movie")
        myRecord.setObject(movie.title, forKey: "title")
        myRecord.setObject(movie.primaryDrive, forKey: "primaryDrive")
        myRecord.setObject(movie.backupDrive, forKey: "backupDrive")
        myRecord.setObject(movie.optical, forKey: "optical")
        myRecord.setObject(movie.type, forKey: "type")
        myRecord.setObject(movie.hd, forKey: "hd")
        
        publicDB.saveRecord(myRecord, completionHandler:
            ({returnRecord, error in
                if let err = error {
                    self.notifyUser("Save error", message: err.localizedDescription)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.notifyUser("Success", message: "Record saved successfully")
                    }
                }
            }))
    }
    
    
    func loadRecords() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Movie", predicate: predicate)
        
        // Sort alphabetically
        let sort = NSSortDescriptor(key: "title", ascending: true)
        query.sortDescriptors = [sort]
        
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.notifyUser("Cloud access error", message: error.localizedDescription)
                }
            } else {
                self.movies.removeAll(keepCapacity: true)
                for record in results {
                    println("added a record to movies")
                    
                    // Add to JMPMoviestore Movies array
                    let movie = JMPMovie(record: record as CKRecord, database: self.publicDB)
                    self.movies.append(movie)
                    
//                    let movie = JMPMovie(title: record.objectForKey?("title") as String,
//                        primaryDrive: record.objectForKey?("primaryDrive") as String,
//                        backupDrive: record.objectForKey?("backupDrive") as String,
//                        optical: record.objectForKey?("optical") as String,
//                        type: record.objectForKey?("type") as String,
//                        hd: record.objectForKey("hd") as Bool)
                    
                    let moviesCount = JMPMovieStore.sharedStore.count
                    println("\(moviesCount) movies in the movieStore")
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                    println()
                }
            }
        }
    }
    
    func deleteRecord(movie: JMPMovie) {
        println("Called JMPMovieStore deleteRecord:")
        
        if let record = movie.record {
            publicDB.deleteRecordWithID(record.recordID, completionHandler: ({returnRecord, error in
                if let err = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.notifyUser("Delete Error", message: err.localizedDescription)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.notifyUser("Success", message: "Record deleted successfully")
                    }
                }
            }))
        } else {
            notifyUser("No record selected", message: "Use Query to select record to delete")
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
}
