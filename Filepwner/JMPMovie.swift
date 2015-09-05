//
//  JMPMovie.swift
//  Filepwner
//
//  Created by Jason Pilz on 1/10/15.
//  Copyright (c) 2015 PilzArche. All rights reserved.
//

import UIKit
import CloudKit

class JMPMovie: NSObject {
    
    // MARK: - Properties
    
    var record: CKRecord!
    weak var database: CKDatabase!
    var title: String!
    var seriesTitle: String?
    var primaryDrive: String?
    var backupDrive: String?
    var optical: String?
    var type: String?
    var size: Double?
    var wishList: Bool = false
    var watched: Bool = false
    var hd: Bool = true
    var dateCreated: NSDate?
    
    // MARK: - Initializers
    
    // Used to create record and save to cloud database (AddMovieTableViewController - JMPMovieStore - saveRecord:)
    init(title: String, seriesTitle: String, primaryDrive: String, backupDrive: String, optical: String, type: String, size: Double, wishlist: Bool, watched: Bool, hd: Bool) {
        self.title = title
        self.seriesTitle = seriesTitle
        self.primaryDrive = primaryDrive
        self.backupDrive = backupDrive
        self.optical = optical
        self.type = type
        self.size = size
        self.wishList = wishlist
        self.watched = watched
        self.hd = hd
        self.dateCreated = NSDate()
    }
    
    // Used to populate movies array once records are present in public Database (JMPMovieStore - loadRecords:)
    init(record: CKRecord, database: CKDatabase) {
        self.record = record
        self.database = database
        
        self.title = record.objectForKey("title") as! String!
        self.primaryDrive = record.objectForKey("primaryDrive")as! String!
        self.seriesTitle = record.objectForKey("seriesTitle")as! String!
        self.backupDrive = record.objectForKey("backupDrive") as! String!
        self.optical = record.objectForKey("optical") as! String!
        self.type = record.objectForKey("type") as! String!
        self.size = record.objectForKey("size")as! Double!
        self.wishList = record.objectForKey("wishList") as! Bool!
        self.watched = record.objectForKey("watched") as! Bool!
        self.hd = record.objectForKey("hd") as! Bool!
        self.dateCreated = record.objectForKey("dateCreated") as! NSDate!
    }
   
}
