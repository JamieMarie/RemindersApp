//
//  ReminderListTableViewController.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 12/6/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class ReminderListTableViewController: UITableViewController {
    
    var taskLists: [TaskList] = []
    var dID : String = ""
    var taskdID : String = ""
    var userEmail : String = ""
    let db = Firestore.firestore()
    var reminderList : TaskList = TaskList(active: false, description: "", fullCompletion: false, name: "test", userEmail: "", tasks: [], numTasks: 0, dateCreated: Date.distantPast, taskListID: 0,  color: "")
    
    var reminderListToSend : TaskList = TaskList(active: false, description: "", fullCompletion: false, name: "test", userEmail: "", tasks: [], numTasks: 0, dateCreated: Date.distantPast, taskListID: 0, color: "")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        userEmail = user!.email!
        //taskLists.append(reminderList)
        tableView.dataSource = self
        tableView.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUsersTaskLists()

        tableView.reloadData()
    }
    
    // query for user's task lists
    func getUsersTaskLists() {
        taskLists = []
        let listCollection = db.collection("TaskLists")
        listCollection.whereField("userEmail", isEqualTo: userEmail).whereField("active", isEqualTo: true).getDocuments() { (querySnap, error) in
            if let error = error {
                print("There was an error getting TaskLists documents: \(error)")
            } else {
                for d in querySnap!.documents {
                    // get the data sweetie
                    let active = d.get("active") as! Bool
                    let description = d.get("description") as! String
                    let fullCompletion = d.get("fullCompletion") as! Bool
                    let name = d.get("name") as! String
                    let userEmail = d.get("userEmail") as! String
                    let numTasks = d.get("numTasks") as! Int
                    let dateCreated = d.get("dateCreated") as! Date
                    let taskListID = d.get("taskListID") as! Int
                    let color  = d.get("color") as! String
                    
                    self.reminderList = TaskList(active: active, description: description, fullCompletion: fullCompletion, name: name, userEmail: userEmail, tasks: [], numTasks: numTasks, dateCreated: dateCreated, taskListID: taskListID, color: color)
                    print(self.reminderList.name)
                    
                    self.taskLists.append(self.reminderList)
                    print("Count before leaving loop: \(self.taskLists.count)")
                }
                self.taskLists.sort() {
                    $0.dateCreated > $1.dateCreated
                }
            }
            self.tableView.reloadData()
        }
        print("num task Lists: \(self.taskLists.count)")
        //return self.taskLists.count
        
    }
    @IBAction func createNewList(_ sender: Any) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("Count: \(taskLists.count)")
        return self.taskLists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskListCell", for: indexPath) as! ReminderListTableViewCell
        print("entered")
        cell.listTitle.text = self.taskLists[indexPath.row].name
        print(taskLists[indexPath.row].name)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = self.taskLists[indexPath.row].name
        print("Name: \(name)")
        print(taskLists.count)
        for list in taskLists {
            if(list.name == name) {
                print("FOUND: \(name)")
                self.reminderListToSend = list
            }
        }
        print()
        print("REMINDER LIST: \(reminderListToSend.description)")
        print()

    
        self.performSegue(withIdentifier: "viewTasksSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            let name = taskLists[indexPath.row].name
            let tID = taskLists[indexPath.row].taskListID
            taskLists.remove(at: indexPath.row)
           
            // now we update firestore
            
            let listCollection = db.collection("TaskLists")
            
            listCollection.whereField("userEmail", isEqualTo: self.userEmail).whereField("name", isEqualTo: name).whereField("active", isEqualTo: true).whereField("tID", isEqualTo: tID).getDocuments() { (querySnap, error) in
                if let error = error {
                    print("There was an error getting TaskLists documents: \(error)")
                } else {
                    for d in querySnap!.documents {
                        // get the data sweetie
                        self.dID = d.documentID
                        print("Successfully found doc \(self.dID)")
                    }
                    
                    self.db.collection("TaskLists").document(self.dID).updateData([
                        "active": false]) { error in
                            if let error = error {
                                print("Error updating: \(error)")
                            } else {
                                print("successful update")
                            }
                    }
                    
                    let c = self.db.collection("Tasks")
                    c.whereField("ownedBy", isEqualTo: self.userEmail).whereField("taskList", isEqualTo: name).whereField("taskListID", isEqualTo: tID).whereField("deleted", isEqualTo: false).getDocuments() { (querySnap, error) in
                        if let error = error {
                            print("There was an error getting TaskLists documents: \(error)")
                        } else {
                            for d in querySnap!.documents {
                                // get the data sweetie
                                self.taskdID = d.documentID
                                print("Successfully found doc \(self.taskdID)")
                                //print(taskdID)
                                
                                self.db.collection("Tasks").document(self.taskdID).updateData([
                                    "deleted": true]) { error in
                                        if let error = error {
                                            print("Error updating: \(error)")
                                        } else {
                                            print("successful update")
                                        }
                                }
                                
                            }
                        }
                    }
                    
                    
                    

                }
            }
            
            
            print("DID " + dID)
            
            if (dID != "") {
                print("entered if")
                
                
                
                
                if (taskdID != "") {
                    
                }
                
            }
            
            
            
            
            // now we need to delete all of this lists tasks
            
            tableView.deleteRows(at: [indexPath], with: .automatic)  //includes updating UI so reloading is not necessary
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createNewListSegue" {
            if let destVC = segue.destination as? CreateNewListViewController {
                // opens create new list screen
                // will need to create a delegate to send over the current user
               // destVC.currentUser = self.currentUser
            }
        } else if segue.identifier == "viewTasksSegue" {
            if let destVC = segue.destination as? TasksViewController {
                // opens create new list screen
                destVC.myTaskList = self.reminderListToSend
                // will need to create a delegate to send over the current user
                // destVC.currentUser = self.currentUser
            }
        }
    }
    


}
