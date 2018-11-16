//
//  TaskScreenViewController.swift
//  RemindersApp
//
//  Created by Jamie Penzien on 11/7/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit
import Firebase
// may need to clear cache to install: rm -rf ~/Library/Caches/CocoaPods
// then run pod install
import FirebaseFirestore
//import FirebaseFirestore

var ref: Database!
//FirebaseApp.configure()


class MainScreenViewController: UIViewController {
    
    // initalize our database
    let db = Firestore.firestore()
    
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
