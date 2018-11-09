//
//  ViewController.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian, Jamie Penzien
//  Copyright © 2018 CIS 347. All rights reserved.

import UIKit
import Firebase

class ViewController: UIViewController {

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
        performSegue(withIdentifier: "Register", sender: nil)
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

