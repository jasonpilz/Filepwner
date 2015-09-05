//
//  DismissSegue.swift
//  Filepwner
//
//  Created by Jason Pilz on 1/12/15.
//  Copyright (c) 2015 PilzArche. All rights reserved.
//

import UIKit

@objc(DismissSegue) class DismissSegue: UIStoryboardSegue {
    
    override func perform() {
        if let controller = sourceViewController.presentingViewController! {
            controller.dismissViewControllerAnimated(true, completion: nil);
        }
    }
   
}
