//
//  CreateNewListViewController.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 11/19/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class CreateNewListViewController: UIViewController {
    
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    
    var currentUser : User = User(email: "", firstName: "", lastName: "", id: "", taskLists: [], numTaskLists: 0)
    var doc: DocumentReference!
    var taskList : TaskList = TaskList(active: false, description: "", fullCompletion: false, name: "", userEmail: "", tasks: [], numTasks: 0)
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func saveButton(_ sender: Any) {
        guard let titleData = self.titleField.text, !titleData.isEmpty else { return }
        guard let descriptionData = self.descriptionField.text, !descriptionData.isEmpty else { return }

        doc = db.document("TaskLists/\(currentUser.email)-\(titleData)")
        let taskListData : [String: Any] = [
            "active": true,
            "description": descriptionData,
            "fullCompletion": false,
            "name": titleData,
            "userEmail": currentUser.email,
            "tasks": [],
            "numTasks": 0
        ]
        taskList = TaskList(active: true, description: descriptionData, fullCompletion: false, name: titleData, userEmail: currentUser.email, tasks: [], numTasks: 0)
        
        doc.setData(taskListData) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Data was saved")
            }
        }
        
        // we also need to update the user
        print("starting user transaction")
        let uReference = db.document("Users/\(currentUser.email)")
        db.runTransaction({(transaction, error) -> Any? in
            let uDoc: DocumentSnapshot
            do {
                try uDoc = transaction.getDocument(uReference)
            } catch let fetchError as NSError {
                error?.pointee = fetchError
                return nil
            }
            
            guard let prevNumLists = uDoc.data()?["numTaskLists"] as? Int else {
                let err = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve num tasks lists from snapshot \(uDoc)"])
                error?.pointee = err
                return nil
            }
            
            transaction.updateData(["numTaskLists": prevNumLists + 1], forDocument: uReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Failed transaction")
            } else {
                print("Successful Transaction")
            }
        
        }
        
        // need to create a delagate here?
        
        self.navigationController?.popViewController(animated: true)
        
        // now we also need to update the user doc
//        var userDoc : DocumentReference! = db.document("Users\(currentUser.email)")
//        userDoc.updateData([
//            "taskList" : FieldValue.arrayUnion([taskList])])
//
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.navigationController?.popViewController(animated:true)
    }
    

}
