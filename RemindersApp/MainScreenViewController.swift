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
import MapKit
import CoreLocation

var ref: Database!

class MainScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate{
    
    // initalize our database
    lazy var db = Firestore.firestore()
    var doc: DocumentReference!
    @IBOutlet weak var tableView: UITableView!
    var userEmail : String = ""
    var tasks : [Task] = []
    var taskdID : String = ""
    var dID : String = ""
    let locationManager = CLLocationManager()
    var lat : Double = 0.0
    var lon : Double = 0.0
    let qAPI = FavQService.getInstance()

    var dailyTask : Task = Task(completed: false, deleted: false, description: "", priority: "", title: "", dateCreated: Date(), expectedCompletion: Date(), actualCompletion: Date(), ownedBy: "", taskList: "")
    
    @IBOutlet weak var taskCompletion: UILabel!
    
    override func viewDidLoad() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        if Auth.auth().currentUser != nil {
            // User is signed in.
            print("Signed in")
            let user = Auth.auth().currentUser;
            userEmail = user!.email!
            print("User email:" + user!.email!)
            
            
        } else {
            print("Not signed in")
        }
        
        qAPI.getQuoteOfTheDay() { (quote) in
            if let q = quote {
                DispatchQueue.main.async {
                    print()
                    print("somehow entered")
                    print(q.author)
                    print(q.quote)
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.auth().currentUser != nil {
            // User is signed in.
            print("Signed in")
            let user = Auth.auth().currentUser;
            userEmail = user!.email!

            print("User email:" + user!.email!)
            
            
        } else {
            print("Not signed in")
        }
        
        getMyTasks()
        getAllMyTasks()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("Count: \(tasks.count)")
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    @IBAction func signOutButton(_ sender: Any) {
        let signOutPrompt = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: UIAlertControllerStyle.alert)
        
        signOutPrompt.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            do {
                try Auth.auth().signOut()
                print("Logged out")
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }))
        
        signOutPrompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Sign out cancelled")
        }))
        
        present(signOutPrompt, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statCell", for: indexPath) as! StatTableViewCell
        print("entered")
        cell.taskTitleLabel.text = self.tasks[indexPath.row].title
        cell.taskListNameLabel.text = self.tasks[indexPath.row].taskList
        print(tasks[indexPath.row].title)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let name = self.tasks[indexPath.row].title


    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = UIContextualAction(style: .normal, title: "Complete") { action, index, completion in
            // do the stuff
            let name = self.tasks[indexPath.row].title
            let taskList = self.tasks[indexPath.row].taskList
            self.tasks.remove(at: indexPath.row)

            var myTask = Task(completed: false, deleted: false, description: "", priority: "", title: "", dateCreated: Date(), expectedCompletion: Date(), actualCompletion: Date(), ownedBy: "", taskList: "")

            for t in self.tasks {
                if name == t.title {
                    myTask = t
                }
            }

            let c = self.db.collection("Tasks")
            c.whereField("ownedBy", isEqualTo: self.userEmail).whereField("taskList", isEqualTo: taskList).whereField("title", isEqualTo: name).whereField("deleted", isEqualTo: false).getDocuments() { (querySnap, error) in
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
                "userEmail" : self.userEmail,
                "datePosted" : Date(),
                "postType" : "CompletedTask",
                "taskName" : name,
                "taskListName" : taskList,
                "lat" : self.lat,
                "lon" : self.lon
            ]

            postDoc.setData(postData) { (error) in
                if let error = error {
                    print("Error setting data: \(error.localizedDescription)")
                } else {
                    print("Data was saved")
                }
            }


            tableView.deleteRows(at: [indexPath], with: .automatic)  //includes updating UI so reloading is not necessary

        }
        complete.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [complete])

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { action, index, completion in
            // do the stuff
            let name = self.tasks[indexPath.row].title
            let taskList = self.tasks[indexPath.row].taskList
            self.tasks.remove(at: indexPath.row)

            let c = self.db.collection("Tasks")
            c.whereField("ownedBy", isEqualTo: self.userEmail).whereField("taskList", isEqualTo: taskList).whereField("title", isEqualTo: name).whereField("deleted", isEqualTo: false).getDocuments() { (querySnap, error) in
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
    
    func getAllMyTasks() {
        var totalCount : Int = 0
        var completedCount : Int = 0
        
        let calendar = Calendar.current
        
        db.collection("Tasks").whereField("ownedBy", isEqualTo: userEmail).whereField("deleted", isEqualTo: false).getDocuments() { (querySnap, error) in
            if let error = error {
                print("Error: \(error)")
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
                
                var final : Double = 0.0
                if (completedCount > 0 && totalCount > 0) {
                    final = (Double(completedCount) / Double(totalCount)) * 100
                }
                //print(completedCount)
                //print(totalCount)
                //print(completedCount/totalCount * 100)
                self.taskCompletion.text = "\(final)%"
                
            }
            
        }
    }
   
    // query for tasks
    func getMyTasks() {
        print()
        print("THIS FUNCTION WAS CALLED")
        print()
        tasks = []
        let calendar = Calendar.current
        let listCollection = db.collection("Tasks")
        listCollection.whereField("ownedBy", isEqualTo: userEmail).whereField("deleted", isEqualTo: false).whereField("completed", isEqualTo: false).getDocuments() { (querySnap, error) in
            if let error = error {
                print("There was an error getting TaskLists documents: \(error)")
            } else {
                for d in querySnap!.documents {
                    print("a doc exists")
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
                    
                    if calendar.isDateInToday(expectedCompletion) {
                        print("a date exists")
                        self.dailyTask = Task(completed: completed, deleted: deleted, description: description, priority: priority, title: title, dateCreated: dateCreated, expectedCompletion: expectedCompletion, actualCompletion: actualCompletion, ownedBy: ownedBy, taskList: taskList)
                        
                        
                        self.tasks.append(self.dailyTask)
                        print("Count before leaving loop: \(self.tasks.count)")
                    }
                   
                }
            }
            self.tableView.reloadData()
        }
        print("num task Lists: \(self.tasks.count)")
        //return self.taskLists.count
        
    }

}
