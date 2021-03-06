//
//  DriverViewController.swift
//  Ridesh
//
//  Created by Shiva Kavya on 2019-04-24.
//  Copyright © 2019 Shiva Kavya. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverViewController: UITableViewController,CLLocationManagerDelegate {

    var rideRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
             if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
              if  (rideRequestDictionary["driverLat"] as? Double) != nil {
             
              }
              else
              {
            self.rideRequests.append(snapshot)
            self.tableView.reloadData()
        }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord = manager.location?.coordinate{
        driverLocation = coord
        }
    }
    

    @IBAction func logoutButtonAction(_ sender: UIBarButtonItem) {
        
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    // MARK: - Table view data source

   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rideRequests.count
       // return 50
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)

        // Configure the cell...
        let snapshot = rideRequests[indexPath.row]
        
        if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
            
            if let email = rideRequestDictionary["email"] as? String {
                
                if let lat = rideRequestDictionary["lat"] as? Double{
                    if let lon = rideRequestDictionary["lon"] as? Double{
                        
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                        let distance = driverCLLocation.distance(from: (riderCLLocation)) / 1000
                        let roundedDistance = round(distance * 100) / 100
                        
                        cell.textLabel?.text = "\(email) - \(roundedDistance)km away"
                    }
                }
                
                
                
                
            }
        }

       // cell.textLabel?.text = "email"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let snapshot = rideRequests[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
                   
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? AcceptRequestViewController{
            if let snapshot = sender as?  DataSnapshot{
                
                
                if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                    
                    if let email = rideRequestDictionary["email"] as? String {
                        
                        if let lat = rideRequestDictionary["lat"] as? Double{
                            if let lon = rideRequestDictionary["lon"] as? Double{
                            
                                acceptVC.requestEmail = email
                            let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                
                                acceptVC.requestLocation = location
                                acceptVC.driverLocation = driverLocation
                            }
                        }
                    }
                }
            }
            
           
        }
    }
    


}
