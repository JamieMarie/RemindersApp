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
    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var _email: UITextField!
    @IBOutlet var _passwordVerify: UITextField!
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
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
                print("Entered")
                
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let detectTouch = UITapGestureRecognizer(target: self, action:
            #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(detectTouch)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    @IBAction func RegisterUser(_ sender: Any) {
        var registerSuccess: Bool = false
        var count = 0
        if _email.text != "" {
            // TODO: CHECK EMAIL DOES NOT ALREADY EXIST
            var random = arc4random_uniform(6) + 1
            var imageString = "Avatar\(random)"
            
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
                                "email" : emailData.lowercased(),
                                "firstName" : "",
                                "id" : "",
                                "lastName" : "",
                                "taskList" : [],
                                "numTaskLists": 0,
                                "streakDate": Date.distantFuture,
                                "streakNum": 0,
                                "friends": [emailData.lowercased()],
                                "profilePic": imageString
                            ]
                            self.ref = self.db.collection("Users").document()
                            
                            self.ref.setData(userData) { (error) in
                                if let error = error {
                                    print("Error: \(error.localizedDescription)")
                                } else {
                                    print("\n")
                                    print("Data was saved")
                                    print("\n")
                                    registerSuccess = true
                                    self.performSegue(withIdentifier: "createUserSegue", sender: self)
                                    //self.dismiss(animated:true, completion: nil)



                                }

                            }
                        }
                    }
                
            } else if _password.text != _passwordVerify.text {
                // Look into implementing this for when content does not pass criteria: https://stackoverflow.com/questions/28883050/swift-prepareforsegue-cancel
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

        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createUserSegue" {
            if let destVC = segue.destination as? CreateUserProfileViewController {
                // open the main screen
                destVC.userEmail = _email.text!
                
            }
        }
    }
}
