//
//  RiderViewController.swift
//  Ridesh
//
//  Created by Shiva Kavya on 2019-04-24.
//  Copyright © 2019 Shiva Kavya. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth
import Intents

class RiderViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet var callRide: UIButton!
  
    
    @IBOutlet var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
   // var driverLocation = CLLocationCoordinate2D()
    var requestLocation = CLLocationCoordinate2D()
    var rideHasBeenCalled = false
    var driverOnTheWay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
   
    
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email {
            
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                self.rideHasBeenCalled = true
                self.callRide.setTitle("Cancel Ride", for: .normal)
                
                Database.database().reference().child("RideRequests").removeAllObservers()
                if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double{
                        if let driverLon = rideRequestDictionary["driverLon"] as? Double{
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                            displayDriverAndRider()
                            
                            if let email = Auth.auth().currentUser?.email { Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged, with: { (snapshot) in
                                if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                                    if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                                        if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                            self.driverOnTheWay = true
                                            displayDriverAndRider()
                                            
                                        }
                                    }
                                }
                            })
                            }
                      }
                    
                    }
                }
            }
            
        }
        
        
    
    
    func displayDriverAndRider()
        {
            let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
            let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
            let roundedDistance = round(distance * 100) / 100
            callRide.setTitle("Your driver is \(roundedDistance)km away!", for: .normal)
            mapView.removeAnnotations(mapView.annotations)
            
            let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
            let lonDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
            
            let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
            mapView.setRegion(region, animated: true)
            
            let riderAnno = MKPointAnnotation()
            riderAnno.coordinate = userLocation
            riderAnno.title = "Your Location"
            mapView.addAnnotation(riderAnno)
            
            let driverAnno = MKPointAnnotation()
            driverAnno.coordinate = driverLocation
            driverAnno.title = "Your Driver"
            mapView.addAnnotation(driverAnno)
            
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord = manager.location?.coordinate
        {
        
           let center =  CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
            
            if rideHasBeenCalled{
               
                displayDriverAndRider()
            }
            else
            {
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Your Location"
            mapView.addAnnotation(annotation)
        }
        }
        }
        
    }
    

    @IBAction func logoutAction(_ sender: Any) {
        
    try? Auth.auth().signOut()
    navigationController?.dismiss(animated: true, completion: nil)
    
    
    }
    
    
    
     @IBAction func callRideAction(_ sender: UIButton) {
        
        if !driverOnTheWay {
        
        if let email = Auth.auth().currentUser?.email
        {
            
            if rideHasBeenCalled
            {
                rideHasBeenCalled = false
                callRide.setTitle("Call Ride", for: .normal)
                
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                    snapshot.ref.removeValue()
                    Database.database().reference().child("RideRequests").removeAllObservers()
                }
                
            }
            else
            {
                let rideRequestDictionary : [String:Any] = ["email":email,"lat":userLocation.latitude,"lon":userLocation.longitude]
                
                Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                rideHasBeenCalled = true
                callRide.setTitle("Cancel Ride", for: .normal)
                
            }
     
        
        }
    
        
    }
    }
    
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
