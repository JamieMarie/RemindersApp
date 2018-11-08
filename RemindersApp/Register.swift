//
//  Register.swift
//  RemindersApp
//
//  Created by Jamie Penzien on 11/7/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseDatabase

class Register: UIViewController {
    
    @IBOutlet var _username: UITextField!
    @IBOutlet var _email: UITextField!
    @IBOutlet var _password: UITextField!
    @IBOutlet var _passwordVerify: UITextField!
    @IBOutlet var _passwordWarning: UILabel!
    var ref: Database!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _passwordWarning.isHidden = true
        ref = Database.database().reference()
        
    }
    
    @IBAction func RegisterUser(_ sender: Any) {
        if _username.text != "" {
            if _email.text != "" {
                if _password.text != ""  && _passwordVerify.text == _password.text {
                    Auth.auth().createUser(withEmail: _email.text!, password: _password.text!) {(user, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        else {
                            print("User signed in!")
                            
                            self.ref.child("data/users").updateChildValues(["\(Auth.auth()!.currentUser!.uid)":["Username":self.username.text!]])
                            
                            self.performSegue(withIdentifier: "home", sender: self)
                            //At this point, the user will be taken to the next screen
                        }
                    } }
                else{
                    print("You left email/password empty")
                }
            } else if _password.text != _passwordVerify.text {
                // Look into implementing this for when content does not pass criteria: https://stackoverflow.com/questions/28883050/swift-prepareforsegue-cancel
                _passwordWarning.isHidden = false
            }
        }
        
    }
}
