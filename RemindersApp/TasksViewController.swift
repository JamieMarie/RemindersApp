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
import MapKit
import CoreLocation

class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var navBarTitle: UINavigationItem!
    var tasks : [Task] = []
    var taskdID : String = ""
    var myTaskList : TaskList = TaskList(active: true, description: "", fullCompletion: false, name: "", userEmail: "", tasks: [], numTasks: 0, dateCreated: Date(), taskListID: 0)
    var task : Task = Task(completed: false, deleted: false, description: "", priority: "", title: "", dateCreated: Date(), expectedCompletion: Date(), actualCompletion: Date(), ownedBy: "", taskList: "", taskListID: 0, taskID: 0)
    let locationManager = CLLocationManager()
    var lat : Double = 0.0
    var lon : Double = 0.0
    var lName : String = ""
    var fName : String = ""

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentUser()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        descriptionLabel.text = myTaskList.description
        tableView.dataSource = self
        tableView.delegate = self
        navBarTitle.title = myTaskList.name
        
        print(Date.distantFuture)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMyTasks()
        tableView.reloadData()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locval : CLLocationCoordinate2D = manager.location!.coordinate
        lon = locval.longitude
        lat = locval.latitude
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func getCurrentUser() {
        db.collection("Users").whereField("email", isEqualTo: myTaskList.userEmail).getDocuments() { querySnap, error in
            if let error = error {
                print("error finding user")
            } else {
                for d in querySnap!.documents {
                    self.fName = d.get("firstName") as! String
                    self.lName = d.get("lastName") as! String
                    
                    
                }
            }
            
        }
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
        

    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = UIContextualAction(style: .normal, title: "Complete") { action, index, completion in
            // do the stuff
            let name = self.tasks[indexPath.row].title
            let taskID = self.tasks[indexPath.row].taskID
            let taskListID = self.tasks[indexPath.row].taskID
            self.tasks.remove(at: indexPath.row)
            
            var myTask = Task(completed: false, deleted: false, description: "", priority: "", title: "", dateCreated: Date(), expectedCompletion: Date(), actualCompletion: Date(), ownedBy: "", taskList: "", taskListID: 0, taskID: 0)
            
            for t in self.tasks {
                if name == t.title {
                    myTask = t
                }
            }
            
            let c = self.db.collection("Tasks")
            c.whereField("ownedBy", isEqualTo: self.myTaskList.userEmail).whereField("taskList", isEqualTo: self.myTaskList.name).whereField("title", isEqualTo: name).whereField("deleted", isEqualTo: false).whereField("taskID", isEqualTo: taskID).getDocuments() { (querySnap, error) in
                if let error = error {
                    print("There was an error getting TaskLists documents: \(error)")
                } else {
                    for d in querySnap!.documents {
                        // get the data sweetie
                        self.taskdID = d.documentID
                        print("Successfully found doc \(self.taskdID)")
                        //print(taskdID)
                        
                        self.db.collection("Tasks").document(self.taskdID).updateData([
                            "completed": true,
                            "actualCompletion": Date()]) { error in
                                if let error = error {
                                    print("Error updating: \(error)")
                                } else {
                                    print("successful update")
                                }
                        }
                        
                    }
                }
            }
            
            // upon completion we need to create a new post
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            let myDate = dateFormatter.string(from: Date())
           
            let postDoc = self.db.collection("Posts").document()
            let postData : [String : Any] = [
               "content" : "Completed \(name) on \(myDate)",
                "userEmail" : self.myTaskList.userEmail,
                "datePosted" : Date(),
                "postType" : "CompletedTask",
                "taskName" : name,
                "taskListName" : self.myTaskList.name,
                "lat" : self.lat,
                "lon" : self.lon,
                "userName" : self.fName + " " + self.lName
                
            ]
            
            postDoc.setData(postData) { (error) in
                if let error = error {
                    print("Error setting data: \(error.localizedDescription)")
                } else {
                    print("Data was saved")
                }
            }
            
            self.createStreakPost()
            
            
            tableView.deleteRows(at: [indexPath], with: .automatic)  //includes updating UI so reloading is not necessary
            
        }
        complete.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [complete])

    }
    
    func createStreakPost() {
        let calendar = Calendar.current
        var completedCount = 0
        var totalCount = 0
        let taskCollection = self.db.collection("Tasks")
        taskCollection.whereField("ownedBy", isEqualTo: self.myTaskList.userEmail).whereField("deleted", isEqualTo: false).getDocuments() { (querySnap, error) in
            if let error = error {
                print("Error")
            } else {
                for d in querySnap!.documents {
                    let completed = d.get("completed") as! Bool
                    let expectedCompletion = d.get("expectedCompletion") as! Date
                    let actualCompletion = d.get("actualCompletion") as! Date
                    
                    if (calendar.isDateInToday(expectedCompletion)) {
                        totalCount += 1
                        if((calendar.isDateInToday(actualCompletion) || (!calendar.isDateInToday(actualCompletion) && actualCompletion < expectedCompletion)) && completed == true) {
                            completedCount += 1
                            
                        }
                        
                    }
                    
                }
                
                // now get current user
                var createPost = false
                //var newDate = Date()
                let userCollection = self.db.collection("Users")
                userCollection.whereField("email", isEqualTo: self.myTaskList.userEmail).getDocuments() { (querySnap, error) in
                    if let error = error {
                        print("Error")
                    } else {
                        for d in querySnap!.documents {
                            let streakDate = d.get("streakDate") as! Date
                            let streakNum = d.get("streakNum") as! Int
                            var myDate = streakDate
                            var id = d.documentID
                            var newNum : Int = streakNum

                            
                            if (calendar.isDateInYesterday(streakDate) && completedCount == totalCount) {
                                newNum = 0
                                newNum = streakNum + 1
                                createPost = true
                                myDate = Date()
                            }
                            if (streakDate == Date.distantFuture && completedCount == totalCount) {
                                newNum = 0
                                newNum = streakNum + 1
                                myDate = Date()
                            }
                            
                            if (completedCount != totalCount && !calendar.isDateInYesterday(streakDate) && !calendar.isDateInYesterday(streakDate)) {
                                newNum = 0
                                myDate = Date()
                            }
                            
                            // now update user
                            self.db.collection("Users").document(id).updateData([
                                "streakDate": myDate, "streakNum": newNum]) { error in
                                    if let error = error {
                                        print("ERROR")
                                    } else {
                                        print("data updated")
                                    }
                            }
                            
                            if createPost {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                                let myDate = dateFormatter.string(from: Date())
                                
                                let postDoc = self.db.collection("Posts").document()
                                let postData : [String : Any] = [
                                    "content" : "\(newNum) day streak!",
                                    "userEmail" : self.myTaskList.userEmail,
                                    "datePosted" : Date(),
                                    "postType" : "Streak",
                                    "taskName" : "",
                                    "taskListName" : "",
                                    "lat": 0.0,
                                    "lon": 0.0,
                                    "userName" : self.fName + " " + self.lName

                                ]
                                
                                postDoc.setData(postData) { (error) in
                                    if let error = error {
                                        print("Error setting data: \(error.localizedDescription)")
                                    } else {
                                        print("Data was saved")
                                    }
                                }                            }
                            
                        }
                    }
                    
                }
            }
        }

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { action, index, completion in
            // do the stuff
            let name = self.tasks[indexPath.row].title
            let taskID = self.tasks[indexPath.row].taskID
            self.tasks.remove(at: indexPath.row)
            
            let c = self.db.collection("Tasks")
            c.whereField("ownedBy", isEqualTo: self.myTaskList.userEmail).whereField("taskList", isEqualTo: self.myTaskList.name).whereField("title", isEqualTo: name).whereField("deleted", isEqualTo: false).whereField("taskID", isEqualTo: taskID).getDocuments() { (querySnap, error) in
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
            
            tableView.deleteRows(at: [indexPath], with: .automatic)  //includes updating UI so reloading is not necessary
            
        }
        delete.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [delete])
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
        
        listCollection.whereField("ownedBy", isEqualTo: myTaskList.userEmail).whereField("taskList", isEqualTo: myTaskList.name).whereField("deleted", isEqualTo: false).whereField("completed", isEqualTo: false).whereField("taskListID", isEqualTo: myTaskList.taskListID).getDocuments() { (querySnap, error) in
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
                    let taskListID = d.get("taskListID") as! Int
                    let taskID = d.get("taskID") as! Int
                    
                    self.task = Task(completed: completed, deleted: deleted, description: description, priority: priority, title: title, dateCreated: dateCreated, expectedCompletion: expectedCompletion, actualCompletion: actualCompletion, ownedBy: ownedBy, taskList: taskList, taskListID: taskListID, taskID: taskID)
                   
                    
                    self.tasks.append(self.task)
                    print("Count before leaving loop: \(self.tasks.count)")
                }
                self.tasks.sort() {
                    $0.dateCreated > $1.dateCreated
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
