//
//  AcceptRequestViewController.swift
//  Ridesh
//
//  Created by Shiva Kavya on 2019-04-25.
//  Copyright © 2019 Shiva Kavya. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AcceptRequestViewController: UIViewController {

    @IBOutlet var mapV: MKMapView!
    
    var driverLocation = CLLocationCoordinate2D()
    var requestLocation = CLLocationCoordinate2D()
    var requestEmail = " "
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapV.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
       
        mapV.addAnnotation(annotation)

    }
    
    @IBAction func acceptRequestAction(_ sender: UIButton) {
        
        //Update the ride request
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat":self.driverLocation.latitude, "driverLon":self.driverLocation.longitude])
            Database.database().reference().child("RideRequests").removeAllObservers()
        
            
            
        }
        
        // Give directions
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placeMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placeMark)
                    mapItem.name = self.requestEmail
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
    
        
    }
    

