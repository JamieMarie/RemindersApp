//
//  CreateUserProfileViewController.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 12/9/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase


class CreateUserProfileViewController: UIViewController{

    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    var userEmail : String = ""
    let db = Firestore.firestore()
    var docID = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            // User is signed in.
            print("Signed in")
            let user = Auth.auth().currentUser;
            userEmail = user!.email!
            print("User email:" + user!.email!)
            
        
            
        } else {
            print("Not signed in seeing this here after register")
        }

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            // User is signed in.
            print("Signed in")
            let user = Auth.auth().currentUser;
            userEmail = user!.email!
            print("User email:" + user!.email!)
            
            
            
        } else {
            print("Not signed in seeing this after register")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateUserPressed(_ sender: Any) {
        
        if (self.firstNameLabel.text!.isEmpty || self.lastNameLabel.text!.isEmpty) {
            let alert = UIAlertController(title: "Error", message: "First Name and Last Name Cannot be Blank", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        guard let firstData = self.firstNameLabel.text, !firstData.isEmpty else { return }
        guard let lastData = self.lastNameLabel.text, !lastData.isEmpty else { return }

        print("fn" + firstData)
        print("ln " + lastData)
        db.collection("Users").whereField("email", isEqualTo: userEmail).getDocuments() { (querySnap, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                for d in querySnap!.documents {
                    self.docID = d.documentID
                    print("found doc")
                    print("doc: " + self.docID)
                    let email = d.get("email") as! String
                    print("Email - " + email)
                }
                // update user data
                self.db.collection("Users").document(self.docID).updateData([
                    "firstName": firstData,
                    "lastName" : lastData]) { error in
                        if let error = error {
                            print("error \(error)")
                        } else {
                            print("sucessful update")
                            self.performSegue(withIdentifier: "finishRegistrationSegue", sender: self)

                            
                        }
                }
                
            }
                            
        }
        
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
