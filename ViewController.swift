//
//  ViewController.swift
//  Ridesh
//
//  Created by Shiva Kavya on 2019-04-24.
//  Copyright © 2019 Shiva Kavya. All rights reserved.
//

import UIKit
import FirebaseAuth
import Intents

class ViewController: UIViewController {

   
    
    @IBOutlet var driverLabel: UILabel!
    @IBOutlet var riderLabel: UILabel!
    @IBOutlet var email: UITextField!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var riderDriverSwitch: UISwitch!
    
    @IBOutlet var signInButton: UIButton!
    
    @IBOutlet var signUpButton: UIButton!
    
    
    var signupMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
     /*   INPreferences.requestSiriAuthorization { (status) in
            
            if status == .authorized {
                print("Siri Access Allowed")
            }
        }  */
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        password.resignFirstResponder()
    }
    
   //Sign Up Action
    @IBAction func siAction(_ sender: UIButton) {
        
       if email.text == "" || password.text == ""
       {
        
        displayAlert(title: "Missing Information", message: "You must enter email & password")
        
        }
        
       else {
        
        if let email = email.text {
            if let password = password.text {
                
              if signupMode
              {
                //SIGN UP
                
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    
                    if error != nil {
                        self.displayAlert(title: "Error", message: error!.localizedDescription)
                    }
                    
                    else
                    {
                        if self.riderDriverSwitch.isOn{
                            //DRIVER
                          let req = Auth.auth().currentUser?.createProfileChangeRequest()
                            req?.displayName = "Driver"
                            req?.commitChanges(completion: nil)
                            
                        }
                        else
                        {
                            //RIDER
                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
                            req?.displayName = "Rider"
                            req?.commitChanges(completion: nil)
                            
                            self.performSegue(withIdentifier: "riderSegue", sender: nil)
                        }
                        
                    }
                    
                    }
                
                }
                
              else{
                
                //Log In
                
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if error != nil {
                        self.displayAlert(title: "Error", message: error!.localizedDescription)
                    }
                        
                    else
                    {
                        let user = Auth.auth().currentUser
                        if user?.displayName == "Driver"
                        {
                            //Driver
                            print("driver")
                            self.performSegue(withIdentifier: "driverSegue", sender: nil)
                        }
                        else{
                            //Rider
                            self.performSegue(withIdentifier: "riderSegue", sender: nil)
                        }
                        
                        
                    }
                }
                
                
                }
                
            }
        }
        
        
        }
   
    
    }
    
    func displayAlert(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
 // Switch to log in action
    @IBAction func suButton(_ sender: UIButton) {
    
        
        if signupMode {
            
            signInButton.setTitle("Log In", for: .normal)
            signUpButton.setTitle("Switch to Sign Up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            signupMode = false
        }
            
        else
            
        {
            
            signInButton.setTitle("Sign Up", for: .normal)
            signUpButton.setTitle("Switch to Log In", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            signupMode = true
            
        }
    
    }
    

}

