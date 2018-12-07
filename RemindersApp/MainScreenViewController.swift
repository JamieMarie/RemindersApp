//
//  TaskScreenViewController.swift
//  RemindersApp
//
//  Created by Jamie Penzien on 11/7/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit
import Firebase
// may need to clear cache to install: rm -rf ~/Library/Caches/CocoaPods
// then run pod install
import FirebaseFirestore

var ref: Database!

class MainScreenViewController: UIViewController {
    
    // initalize our database
    let db = Firestore.firestore()
    var doc: DocumentReference!
    var currentUser : User = User(email: "", firstName: "", lastName: "", id: "", taskLists: [], numTaskLists: 0)
    var taskList : TaskList = TaskList(active: false, description: "", fullCompletion: false, name: "", userEmail: "", tasks: [], numTasks: 0, dateCreated: Date.distantPast)
    @IBOutlet weak var todaysTasks: UITableView!
    
    @IBOutlet weak var createNewList: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createNewList.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // if we're seguing from register we will need to call this from somewhere else
        // will need to look into where else we should call this -> onResume equivalent?
        if Auth.auth().currentUser != nil {
            // User is signed in.
            print("Signed in")
            
            let user = Auth.auth().currentUser;
            
            // now we should also query to see if this user has any task lists
            doc = db.collection("Users").document(user!.email!)
            
            // will need to convert this to a document snapshot but first lets make sure we have everything else working
            doc.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDetail = document.data().map(String.init(describing:)) ?? "nil"
                    print("Doc Data: \(dataDetail)")
                    
                    // if let email = dataDetail["email"], let fName = dataDetail[]
                    var mapValues = [String: Any]()
                    mapValues = document.data()!
                    
                    if let email = mapValues["email"], let fName = mapValues["firstName"], let id = mapValues["id"],let lName = mapValues["lastName"], let tasks = mapValues["taskList"], let numTLists = mapValues["numTaskLists"]{
                        // now we assign the values to our struct
                        self.currentUser = User(email: email as! String, firstName: fName as! String, lastName: lName as! String, id: id as! String, taskLists: tasks as! Array<TaskList>, numTaskLists: numTLists as! Int )
                        
                        print("Email: \(self.currentUser.email)")
                    }
                    
                    self.checkForLists(user: self.currentUser)
                    
                } else {
                    print("doc doesn't exist")
                }
            }
            
            // if user has no task lists prompt them to create one
            // if the user has tasks for today what do we display
            
        } else {
            print("Not signed in")
        }
        
        if (self.isMovingToParentViewController || self.isBeingPresented){
            // Controller is being pushed on or presented.
            self.checkForLists(user: self.currentUser)
        }
        else{
            // Controller is being shown as result of pop/dismiss/unwind.
            self.checkForLists(user: self.currentUser)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createNewListSegue" {
            if let destVC = segue.destination as? CreateNewListViewController {
                // opens create new list screen
                // will need to create a delegate to send over the current user
                destVC.currentUser = self.currentUser
            }
        } else if segue.identifier == "createNewTaskSegue"{
            if let destVC = segue.destination as? CreateNewTaskViewController {
                // opens create new list screen
                // will need to create a delegate to send over the current user
                destVC.currentUser = self.currentUser
                destVC.currentTaskList = self.taskList
            }
        }
    }
    
    @IBAction func createTask(_ sender: Any) {
        performSegue(withIdentifier: "createNewTaskSegue", sender: nil)

    }
    
    func checkForLists(user: User) {
        if (currentUser.numTaskLists == 0) {
            createNewList.isHidden = false
            todaysTasks.isHidden = true
            print("no lists")
            // the user has no lists
            // we need to prompt them to create one
        } else {
            createNewList.isHidden = true
            todaysTasks.isHidden = false
            print("lists")
            
            // this  is  used for  testing and will need to be  removed once  more of the  app is  done
            let taskListsRef = db.collection("TaskLists")
            
            // only want  to return 1  list right now
            let listQuery = taskListsRef.whereField("userEmail", isEqualTo: currentUser.email)
            .limit(to: 1)
            
            listQuery.getDocuments { (qSnap, error) in
                if let qSnap = qSnap, !qSnap.isEmpty {
                    //let docList = document.documents.map(docU) ??
                    for var d in qSnap.documents {
//                        qSnap.documents[0].data().map(String.init(describing:))  ??  "nil"
//                        let listDetail = d.data().map(String.init(describing:)) ?? "nil"
//                        print("Query Data: \(listDetail)")
                        let active = d.get("active") as! Bool
                        let description = d.get("description") as! String
                        let fullCompletion = d.get("fullCompletion") as! Bool
                        let name = d.get("name") as! String
                        let userEmail = d.get("userEmail") as! String
                        let numTasks = d.get("numTasks") as! Int
                        let dateCreated = d.get("dateCreated") as! Date
                        
                        self.taskList = TaskList(active: active, description: description, fullCompletion: fullCompletion, name: name, userEmail: userEmail, tasks: [], numTasks: numTasks, dateCreated: dateCreated)
                    }
                } else {
                    print("no docs")
                }
                
            }

        }
    }
    
    @IBAction func createNewListPressed(_ sender: Any) {
        performSegue(withIdentifier: "createNewListSegue", sender: nil)
    }
    

}
