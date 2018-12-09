//
//  Register.swift
//  RemindersApp
//
//  Created by Jamie Penzien and Kaylin Zaroukian on 11/7/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseDatabase
// for firestore referencing: https://code.tutsplus.com/tutorials/getting-started-with-cloud-firestore-for-ios--cms-30910
import FirebaseFirestore

class SignUpViewController: UIViewController {
    @IBOutlet var _email: UITextField!
    @IBOutlet var _password: UITextField!
    @IBOutlet var _passwordVerify: UITextField!
    @IBOutlet var _passwordWarning: UILabel!
    //var ref: Database!
    let db = Firestore.firestore()
//    var ref: DocumentReference? = nil
    var ref: DocumentReference!
    var p : Bool = false

    var users: [User] = []
    // not positive what this does
    var listener : ListenerRegistration!
    var documents: [DocumentSnapshot] = []
    
//    fileprivate func baseQuery() -> Query {
//        return Firestore.firestore().collection("Users").limit(to: 50)
//    }
    
//    fileprivate var query : Query? {
//        didSet {
//            if let listener = listener {
//                listener.remove()
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _passwordWarning.isHidden = true
        let detectTouch = UITapGestureRecognizer(target: self, action:
            #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(detectTouch)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    @IBAction func RegisterUser(_ sender: Any) {
        var registerSuccess: Bool = false
        var count = 0
        if _email.text != "" {
            // TODO: CHECK EMAIL DOES NOT ALREADY EXIST
            
            db.collection("Users").whereField("email", isEqualTo: _email.text!).getDocuments()  { querySnap, error in
                if let error = error {
                    print("Error: \(error)")
                } else {
                    for d in querySnap!.documents {
                        count += 1
                    }
                    if (count > 0) {
                        print()
                        print("EMAIL EXISTS")
                        let alert = UIAlertController(title: "Error", message: "Email already in use", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        registerSuccess = false
                        return
                    }
                }
            }
            print("Count: \(count)")
            
            if _password.text != ""  && _passwordVerify.text == _password.text {
                
                Auth.auth().createUser(withEmail: _email.text!, password: _password.text!) {(user, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            let alert = UIAlertController(title: "Error", message: "Error Creating Account: Password must be at least 6 characters", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            print("User signed up!")
                            guard let emailData = self._email.text, !emailData.isEmpty else { return }
                            
                            let userData : [String: Any] = [
                                "email" : emailData,
                                "firstName" : "",
                                "id" : "",
                                "lastName" : "",
                                "taskList" : [],
                                "numTaskLists": 0,
                                "streakDate": Date.distantFuture,
                                "streakNum": 0,
                                "friends": [emailData]
                            ]
                            self.ref = self.db.document("Users/\(emailData)")
                            
                            self.ref.setData(userData) { (error) in
                                if let error = error {
                                    print("Error: \(error.localizedDescription)")
                                } else {
                                    print("\n")
                                    print("Data was saved")
                                    print("\n")
                                    registerSuccess = true
                                    self.performSegue(withIdentifier: "finishRegistrationSegue", sender: self)
                                    //self.dismiss(animated:true, completion: nil)



                                }

                            }
                        }
                    }
                
            } else if _password.text != _passwordVerify.text {
                // Look into implementing this for when content does not pass criteria: https://stackoverflow.com/questions/28883050/swift-prepareforsegue-cancel
                _passwordWarning.isHidden = false
                let alert = UIAlertController(title: "Failed", message: "Password doesn't match", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            else{
                print("Please enter a password")
            }
        }
        if registerSuccess == true {

//            self.performSegue(withIdentifier: "finishRegistrationSegue", sender: self)
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
//    override func shouldPerformSegue(identifier: String, sender: Any?) -> Bool {
//        //super.shouldPerformSegue()
//        if identifier == "finishRegistrationSegue"{
//            if p == false {
//                //fire an alert controller about the error
//                return false
//            }
//        }
//
//        //Continue with the segue
//        return true
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finishRegistrationSegue" {
            if let destVC = segue.destination.childViewControllers[0] as? MainScreenViewController {
                // open the main screen
                if p == false {
                    return
                }
            }
        }
    }
}
