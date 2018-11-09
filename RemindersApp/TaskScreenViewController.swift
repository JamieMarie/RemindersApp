//
//  TaskScreenViewController.swift
//  RemindersApp
//
//  Created by Jamie Penzien on 11/7/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit
import Firebase
var ref: Database!

class TaskScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            // User is signed in.
            print("Signed in")
            
        } else {
            print("Not signed in")
        }
    }


}
