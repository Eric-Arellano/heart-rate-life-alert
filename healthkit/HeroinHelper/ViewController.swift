//
//  ViewController.swift
//  HeroinHelper
//
//  Created by Steven Sawtelle on 1/14/17.
//  Copyright © 2017 Steven Sawtelle. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var monitoringActivated = false
    
    var locationManager = CLLocationManager()
    var location = CLLocation()
    var heartRateTimer = Timer()
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var contactPreference: UISwitch!
    @IBOutlet weak var emergencyName: UITextField!
    @IBOutlet weak var emergencyNumber: UITextField!
    @IBOutlet weak var contactCause: UITextField!
    
    
    // ---------------------------------------------------------------------
    // Setup / UI
    // ---------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocationMangager()
        dismissKeyboardOnTap()
    }
    
    func setUpLocationMangager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
    }

    func dismissKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // ---------------------------------------------------------------------
    // Overall start monitoring
    // ---------------------------------------------------------------------
    
    //Called with every press of main button
    @IBAction func startMonitoring(_ sender: UIButton) {
        monitoringActivated = true
        HTTPRequests.postJSON(json: getContactInfo(),
                 suffix: "contact-info")
        HTTPRequests.postJSON(json: getLatLong(),
                 suffix: "location")
        notifyContactOfMonitoring()
        createHeartRateTimer()
    }
    
    func notifyContactOfMonitoring(){
        let json: [String: Any] = ["start-monitoring": "start-monitoring"]
        HTTPRequests.postJSON(json: json, suffix: "start-monitoring")
    }
    
 
    // ---------------------------------------------------------------------
    // Heart rate
    // ---------------------------------------------------------------------
    
    func createHeartRateTimer() {
        heartRateTimer.invalidate()
        heartRateTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                     target: self,
                                     selector: #selector(getAndCheckHeartRate),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func getAndCheckHeartRate(){
        let heartRateJSON = HeartRate.getHeartRate()
        let heartRate = heartRateJSON["heart_rate"] as! Int
        if (HeartRateInterpreter.isSimpleOverdose(heartRate: heartRate)) {
            if (self.confirmInDanger()) {
                self.triggerMasterKill()
            }
        }
    }
    
    // ---------------------------------------------------------------------
    // Location
    // ---------------------------------------------------------------------
    
    func getLatLong() -> [String: Any] {
        let currentLocation = locationManager.location
        let longitude_numeric = NSNumber(value: currentLocation!.coordinate.longitude)
        let latitude_numeric = NSNumber(value: currentLocation!.coordinate.latitude)
        let longitude = longitude_numeric.stringValue
        let latitude = latitude_numeric.stringValue
        return ["latitude": latitude, "longitude": longitude]
    }

    
    //Get first location (most recent, relevant one) whenever location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations[0]
    }
    
    
    // ---------------------------------------------------------------------
    // Contact info
    // ---------------------------------------------------------------------
    
    func getContactInfo() -> [String: Any] {
        let name = emergencyName.text
        let number = emergencyNumber.text
        let cause = contactCause.text
        let preference = "" + (contactPreference.isOn ? "text" : "call")
        return ["contact_name": name, "contact_number": number, "contact_preference": preference, "contact_cause": cause]
    }
    
    
    // ---------------------------------------------------------------------
    // Check false positive
    // ---------------------------------------------------------------------
    
    var inDanger = Bool()
    
    func confirmInDanger() -> Bool {
        let alertController = UIAlertController(title: "Are you ok?",
                                                message:"We will contact your emergency contact with your location if you don't respond in the next 30 seconds",
                                                preferredStyle: .alert)
        
        let action = UIAlertAction(title: "I am ok",
                                   style: .default,
                                   handler: self.markFalseNegative)
        alertController.addAction(action)
        DispatchQueue.main.async {
            self.present(alertController,
                         animated: true,
                         completion: nil)
            _ = Timer.scheduledTimer(timeInterval: 20.0,
                                     target: self,
                                     selector: #selector(self.markInDanger),
                                     userInfo: nil,
                                     repeats: false)
        }
        return inDanger
    }
    
    func markFalseNegative(alert: UIAlertAction!) {
        inDanger = false
    }
    
    func markInDanger() {
        inDanger = true
    }
    
    
    // ---------------------------------------------------------------------
    // Kill/overdose
    // ---------------------------------------------------------------------
    
    func triggerMasterKill(){
        let json: [String: Any] = ["master-kill": "master-kill"]
        HTTPRequests.postJSON(json: json, suffix: "master-kill")
    }

    
    @IBAction func triggerSimulatedKill(_ sender: UIButton) {
        if(monitoringActivated == true) {
            triggerMasterKill()
        } else {
            monitoringActivated = false
        }
    }
    
    
    // ---------------------------------------------------------------------
    // Stop monitoring
    // ---------------------------------------------------------------------
    
    @IBAction func stopMonitoring(_ sender: UIButton) {
        if (monitoringActivated == true) {
            stopHeartRateTimer()
            notifyServerStopMonitoring()
            } else {
            monitoringActivated = false
        }
    }
    
    func stopHeartRateTimer(){
        heartRateTimer.invalidate()
    }
    
    func notifyServerStopMonitoring() {
        let json: [String: Any] = ["stop": "stop"]
        HTTPRequests.postJSON(json: json, suffix: "stop-app")
    }

}

