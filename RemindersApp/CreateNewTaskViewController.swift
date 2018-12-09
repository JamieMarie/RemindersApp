//
//  CreateNewTaskViewController.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 11/28/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class CreateNewTaskViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var expectedCompletionLabel: UILabel!
    @IBOutlet weak var completionDatePicker: UIDatePicker!
    var currentUser : User = User(email: "", firstName: "", lastName: "", id: "", taskLists: [], numTaskLists: 0, streakDate: Date.distantFuture, streakNum: 0, friends: [])
    var currentTaskList : TaskList = TaskList(active: false, description: "", fullCompletion: false, name: "", userEmail: "", tasks: [], numTasks: 0, dateCreated: Date(), taskListID: 0)
    var newTask : Task = Task(completed: false, deleted: false, description: "", priority: "", title: "", dateCreated: Date.distantFuture, expectedCompletion: Date.distantFuture, actualCompletion: Date.distantFuture, ownedBy: "",taskList: "", taskListID: 0, taskID: 0)
    var toComplete: Date = Date()
    var dateFormatter : DateFormatter = DateFormatter()
    var taskDoc : DocumentReference!
    let db = Firestore.firestore()
    let  dummyDate  = Date(timeIntervalSince1970: -123456789.0)
    var userEmail : String = ""
    var docID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userEmail = Auth.auth().currentUser!.email!
        queryCurrentList()
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:min"
        expectedCompletionLabel.text = dateFormatter.string(from: Date())
        
        // will need to  put this  in a separate function
        completionDatePicker.timeZone = NSTimeZone.local
        completionDatePicker.backgroundColor = UIColor.white
        completionDatePicker.datePickerMode = .dateAndTime
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
//        self.expectedCompletionLabel.addGestureRecognizer(tap)
        
        self.completionDatePicker.isHidden = false
        let detectTouch = UITapGestureRecognizer(target: self, action:
            #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(detectTouch)


        // Do any additional setup after loading the view.
        
        // going to need to add listeners for page clicks and stuff but don't feel like doing that rn
    }
    
//    @objc func tapped(sender: UITapGestureRecognizer){
//        print("gesture recognizer tapped.")
//        self.completionDatePicker.isHidden = false
//
//    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        self.navigationController?.popViewController(animated:true)

    }
    @IBAction func saveButton(_ sender: Any) {
        
        if (self.titleField.text!.isEmpty ) {
            let alert = UIAlertController(title: "Error", message: "Task Title Cannot be Blank", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        guard let titleData = self.titleField.text, !titleData.isEmpty else { return }
        var taskID : Int = Int(arc4random_uniform(4294967291))
        
        taskDoc = db.collection("Tasks").document()
        let taskData : [String : Any] = [
            "completed" : false,
            "deleted" : false,
            "description" : "",
            "priority" : "",
            "title" : titleData,
            "dateCreated" : Date(),
            "expectedCompletion"  :  toComplete ,
            "actualCompletion" : dummyDate,
            "ownedBy" : userEmail,
            "taskList" : currentTaskList.name,
            "taskListID" : currentTaskList.taskListID,
            "taskID" : taskID
        ]
        
        newTask = Task(completed: false, deleted: false, description: "", priority: "", title: titleData, dateCreated: Date(), expectedCompletion: toComplete, actualCompletion: dummyDate, ownedBy: currentUser.email, taskList: currentTaskList.name, taskListID: currentTaskList.taskListID, taskID: taskID)
        
        taskDoc.setData(taskData) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Data was saved")
            }
        }
        
        // update the parent task list
        let uReference = db.collection("TaskLists").document(docID)
        
        db.runTransaction({(transaction, error) -> Any? in
            let uDoc: DocumentSnapshot
            do {
                try uDoc = transaction.getDocument(uReference)
            } catch let fetchError as NSError {
                error?.pointee = fetchError
                return nil
            }
            
            guard let prevNumTasks = uDoc.data()?["numTasks"] as? Int else {
                let err = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve num tasks lists from snapshot \(uDoc)"])
                error?.pointee = err
                return nil
            }
            
            transaction.updateData(["numTasks": prevNumTasks + 1], forDocument: uReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Failed transaction")
            } else {
                print("Successful Transaction")
            }
            
        }
        self.navigationController?.popViewController(animated:true)

    }
    @IBAction func datePickerPressed(_ sender: Any) {
        print()
        print("Clicker clicked")
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:min"
        expectedCompletionLabel.text = dateFormatter.string(from: completionDatePicker.date)
        print(expectedCompletionLabel.text!)
        toComplete = completionDatePicker.date
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func queryCurrentList() {
        let collection = db.collection("TaskLists")
        collection.whereField("userEmail", isEqualTo: userEmail).whereField("name", isEqualTo: currentTaskList.name).whereField("taskListID", isEqualTo: currentTaskList.taskListID).getDocuments() { (querySnap, error) in
            if let error = error {
                print("Error getting users: \(error)")
            } else {
                for d in querySnap!.documents {
                    self.docID = d.documentID
                    print(self.docID)
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
