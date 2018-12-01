//
//  ViewController.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian, Jamie Penzien
//  Copyright © 2018 CIS 347. All rights reserved.

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet var _username: UITextField!
    @IBOutlet var _password: UITextField!
    @IBOutlet var _loginButton: UIButton!
    @IBOutlet var _registerButton: UIButton!
    var ref: Database!
    
    @IBAction func LoginButton(_ sender: Any) {
        var loginSuccess: Bool = false
        if _username.text != "" {
            if _password.text != "" {
                Auth.auth().signIn(withEmail: _username.text!, password: _password.text!) {
                    (user, error) in
                    if let error = error {
                        print("There was an error doing: ")
                        print(error.localizedDescription)
                    }
                    else {
                        print("User signed in!")
                        loginSuccess = true
                    }
                }
            }
        }
        if loginSuccess == true {
            performSegue(withIdentifier: "Login", sender: nil)
        }
        
    }
    
    @IBAction func RegisterButton(_ sender: Any) {
        self.performSegue(withIdentifier: "registerNewUserSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSegue" {
            if let destVC = segue.destination.childViewControllers[0] as? MainScreenViewController {
                // open the main screen
            }
        }
        if segue.identifier == "registerNewUserSegue" {
            if let destVC = segue.destination as? SignUpViewController {
                // open the sign up screen
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

