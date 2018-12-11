//
//  RemindTabBarController.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 12/9/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class RemindTabBarController: UITabBarController {

    override func viewDidLoad() {
        self.view.backgroundColor = BACKGROUND_COLOR
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // not sure
                print("logged in")
                for child in self.childViewControllers {
                    if let nc = child as? UINavigationController {
                        if let c = nc.childViewControllers[0]
                            as? MainScreenViewController {
                            c.userEmail = user.email!
                        }
                    }
                }
            } else {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }

        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func unwindFromSignup(segue: UIStoryboardSegue) {
        // we end up here when the user signs up for a new account.
        print("We get here before segue")
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
