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
    
    let title: String!
    let primaryDrive: String?
    let backupDrive: String?
    let optical: String?
    let type: String?
    let hd: Bool = true
    
    // MARK: - Initializer
    
    // Used to create record and save to cloud database (AddMovieTableViewController - JMPMovieStore - saveRecord:)
    init(title: String, primaryDrive: String, backupDrive: String, optical: String, type: String, hd: Bool) {
        self.title = title
        self.primaryDrive = primaryDrive
        self.backupDrive = backupDrive
        self.optical = optical
        self.type = type
        self.hd = hd
    }
    
    // Used to populate movies array once records are present in public Database (JMPMovieStore - loadRecords:)
    init(record: CKRecord, database: CKDatabase) {
        self.record = record
        self.database = database
        
        self.title = record.objectForKey("title") as String!
        self.primaryDrive = record.objectForKey("primaryDrive") as String!
        self.backupDrive = record.objectForKey("backupDrive") as String!
        self.optical = record.objectForKey("optical") as String!
        self.type = record.objectForKey("type") as String!
        self.hd = record.objectForKey("hd") as Bool!
    }
   
}
