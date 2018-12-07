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
    var userEmail : String = "kaylinz47@outlook.com"
    let db = Firestore.firestore()
    var reminderList : TaskList = TaskList(active: false, description: "", fullCompletion: false, name: "", userEmail: "", tasks: [], numTasks: 0, dateCreated: Date.distantPast)
    
    // query for user's task lists
    func getUsersTaskLists() -> Int {
        let listCollection = db.collection("TaskLists")
        listCollection.whereField("userEmail", isEqualTo: userEmail).getDocuments() { (querySnap, error) in
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
                    
                    self.reminderList = TaskList(active: active, description: description, fullCompletion: fullCompletion, name: name, userEmail: userEmail, tasks: [], numTasks: numTasks, dateCreated: dateCreated)
                    print(self.reminderList.name)
                    
                    self.taskLists.append(self.reminderList)
                    print("Count before leaving loop: \(self.taskLists.count)")
                }
            }
        }
        print("num task Lists: \(self.taskLists.count)")
        return self.taskLists.count
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        let semaphore = DispatchSemaphore(value: 0)
//
//        self.getUsersTaskLists() {
//            semaphore.signal()
//        }
//        semaphore.wait()
//        let queue = DispatchQueue(label: "queue1")
//        queue.async {
//            self.getUsersTaskLists()
//        }
        
        var c = 0
        while(c < 1) {
            c = self.taskLists.count
        }

        //getUsersTaskLists()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
