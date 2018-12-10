//
//  MapViewController.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 12/8/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import Firebase

class MapViewController: UIViewController, CLLocationManagerDelegate {
    let db = Firestore.firestore()
    let locationManager = CLLocationManager()
    var lat : Double = 0.0
    var lon : Double = 0.0
    var spots : [[String:Any]] = []
    var userEmail : String = ""

    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        userEmail = Auth.auth().currentUser!.email!
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        if !CLLocationManager.locationServicesEnabled() {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please Enable Location Services to Use the Map", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locval : CLLocationCoordinate2D = manager.location!.coordinate
        lon = locval.longitude
        lat = locval.latitude
        let view = MKCoordinateRegionMakeWithDistance((locations.last!.coordinate) , 600, 600)
        self.mapView.setRegion(view, animated: true)
    }
    
    func getPosts() {
        //posts = []
        spots = []
        
        
        var friends : [String] = []
        db.collection("Users").whereField("email", isEqualTo: userEmail).getDocuments() { (querySnap, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                for d in querySnap!.documents {
                    
                    friends = d.get("friends") as! [String]
                }
                let postCollection = self.db.collection("Posts")
                
                postCollection.getDocuments() { (querySnap, error) in
                    if let error = error {
                        print("There was an error getting Posts document: \(error)")
                    } else {
                        for d in querySnap!.documents {
                            let content = d.get("content") as! String
                            let userEmail = d.get("userEmail") as! String
//                            let datePosted = d.get("datePosted") as! Date
                            let postType = d.get("postType") as! String
                            let taskName = d.get("taskName") as! String
//                            let taskListName = d.get("taskListName") as! String
                            let lon = d.get("lon") as! Double
                            let lat = d.get("lat") as! Double
                            let userName = d.get("userName") as! String
                            
                            // check here if userEmail is in friends
                            if friends.contains(userEmail) && postType == "CompletedTask" && lat != 0 && lon != 0{
                                var postLocationData : [String : Any] = [
                                    "content" : content,
                                    "lat" : lat,
                                    "lon" : lon
                                ]
                                self.spots.append(postLocationData)
                                let marker = MKPointAnnotation()
                                marker.title = userName + " completed " + taskName
                                marker.coordinate = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: lon as! CLLocationDegrees)
                                self.mapView.addAnnotation(marker)
                                
//                                self.currentPost = Post(content: content, userEmail: userEmail, datePosted: datePosted, postType: postType, taskListName: taskListName, taskName: taskName, lat: lat, lon: lon)
                            }
                            
                        }
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
