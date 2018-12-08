//
//  TasksViewController.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 12/7/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var navBarTitle: UINavigationItem!
    var tasks : [Task] = []
    var myTaskList : TaskList = TaskList(active: true, description: "", fullCompletion: false, name: "", userEmail: "", tasks: [], numTasks: 0, dateCreated: Date())
    var task : Task = Task(completed: false, deleted: false, description: "", priority: "", title: "", dateCreated: Date(), expectedCompletion: Date(), actualCompletion: Date(), ownedBy: "", taskList: "")

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = myTaskList.description
        tableView.dataSource = self
        tableView.delegate = self
        navBarTitle.title = myTaskList.name

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMyTasks()
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("Count: \(tasks.count)")
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        print("entered")
        cell.taskTitle.text = self.tasks[indexPath.row].title
        print(tasks[indexPath.row].title)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let name = self.tasks[indexPath.row].title

//        self.performSegue(withIdentifier: "createNewTaskSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createNewTaskSegue" {
            if let destVC = segue.destination as? CreateNewTaskViewController {
                // opens create new list screen
                // will need to create a delegate to send over the current user
                destVC.currentTaskList = myTaskList
            }
        }
    }
    
    // query for tasks
    func getMyTasks() {
        tasks = []
        let listCollection = db.collection("Tasks")
        listCollection.whereField("ownedBy", isEqualTo: myTaskList.userEmail).whereField("taskList", isEqualTo: myTaskList.name).whereField("deleted", isEqualTo: false).getDocuments() { (querySnap, error) in
            if let error = error {
                print("There was an error getting TaskLists documents: \(error)")
            } else {
                for d in querySnap!.documents {
                    // get the data sweetie
                    let actualCompletion = d.get("actualCompletion") as! Date
                    let completed = d.get("completed") as! Bool
                    let deleted = d.get("deleted") as! Bool
                    let dateCreated = d.get("dateCreated") as! Date
                    let description = d.get("description") as! String
                    let expectedCompletion = d.get("expectedCompletion") as! Date
                    let ownedBy = d.get("ownedBy") as! String
                    let priority = d.get("priority") as! String
                    let taskList = d.get("taskList") as! String
                    let title = d.get("title") as! String
                    
                    self.task = Task(completed: completed, deleted: deleted, description: description, priority: priority, title: title, dateCreated: dateCreated, expectedCompletion: expectedCompletion, actualCompletion: actualCompletion, ownedBy: ownedBy, taskList: taskList)
                   
                    
                    self.tasks.append(self.task)
                    print("Count before leaving loop: \(self.tasks.count)")
                }
            }
            self.tableView.reloadData()
        }
        print("num task Lists: \(self.tasks.count)")
        //return self.taskLists.count
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addTaskClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "createNewTaskSegue", sender: self)
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
