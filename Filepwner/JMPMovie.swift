//
//  JMPMovie.swift
//  Filepwner
//
//  Created by Jason Pilz on 1/10/15.
//  Copyright (c) 2015 PilzArche. All rights reserved.
//

import UIKit

class JMPMovie: NSObject {
    
    let title: String
    let primaryDrive: String?
    let backupDrive: String?
    let optical: String?
    let type: String?
    let hd: Bool = true
    
    init(title: String, primaryDrive: String, backupDrive: String, optical: String, type: String, hd: Bool){
        self.title = title
        self.primaryDrive = primaryDrive
        self.backupDrive = backupDrive
        self.optical = optical
        self.type = type
        self.hd = hd
    }
   
}
