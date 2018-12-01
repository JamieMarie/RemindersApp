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
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var expectedCompletionLabel: UILabel!
    @IBOutlet weak var completionDatePicker: UIDatePicker!
    var currentUser : User = User(email: "", firstName: "", lastName: "", id: "", taskLists: [], numTaskLists: 0)
    var currentTaskList : TaskList = TaskList(active: false, description: "", fullCompletion: false, name: "", userEmail: "", tasks: [], numTasks: 0)
    var newTask : Task = Task(completed: false, description: "", priority: "", title: "", dateCreated: Date.distantFuture, expectedCompletion: Date.distantFuture, actualCompletion: Date.distantFuture, ownedBy: "",taskList: "")
    var toComplete: Date = Date()
    var dateFormatter : DateFormatter = DateFormatter()
    var taskDoc : DocumentReference!
    let db = Firestore.firestore()
    let  dummyDate  = Date(timeIntervalSince1970: -123456789.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // will need to  put this  in a separate function
        completionDatePicker.timeZone = NSTimeZone.local
        completionDatePicker.backgroundColor = UIColor.white
        completionDatePicker.datePickerMode = .dateAndTime
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        self.expectedCompletionLabel.addGestureRecognizer(tap)
        
        self.completionDatePicker.isHidden = false


        // Do any additional setup after loading the view.
        
        // going to need to add listeners for page clicks and stuff but don't feel like doing that rn
    }
    
    @objc
    func tapped(sender: UITapGestureRecognizer){
        print("gesture recognizer tapped.")
        self.completionDatePicker.isHidden = false
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.navigationController?.popViewController(animated:true)

    }
    @IBAction func saveButton(_ sender: Any) {
        guard let titleData = self.titleField.text, !titleData.isEmpty else { return }
        guard let descriptionData = self.descriptionField.text, !descriptionData.isEmpty else{ return }
        
        let random = arc4random()
        taskDoc = db.document("Tasks/\(currentUser.email)-\(currentTaskList.name)-\(random)")
        let taskData : [String : Any] = [
            "completed" : false,
            "description" : descriptionData,
            "priority" : "",
            "title" : titleData,
            "dateCreated" : Date(),
            "expectedCompletion"  :  toComplete ,
            "actualCompletion" : dummyDate,
            "ownedBy" : currentUser.email,
            "taskList" : currentTaskList.name
        ]
        
        newTask = Task(completed: false, description: descriptionData, priority: "", title: titleData, dateCreated: Date(), expectedCompletion: toComplete, actualCompletion: dummyDate, ownedBy: currentUser.email, taskList: currentTaskList.name)
        
        taskDoc.setData(taskData) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Data was saved")
            }
        }
        
        // update the parent task list
        let uReference = db.document("TaskLists/\(currentUser.email)-\(currentTaskList.name)")
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
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:min"
        expectedCompletionLabel.text = dateFormatter.string(from: completionDatePicker.date)
        toComplete = completionDatePicker.date
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
