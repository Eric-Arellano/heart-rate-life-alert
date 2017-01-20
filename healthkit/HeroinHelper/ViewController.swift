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
import HealthKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locManager = CLLocationManager()
    let healthStore = HKHealthStore()
    var location = CLLocation()
    var heartRateTimer = Timer()
    var inDanger = false
    
    @IBOutlet weak var contactPreference: UISwitch!
    @IBOutlet weak var emergencyName: UITextField!
    @IBOutlet weak var emergencyNumber: UITextField!
    @IBOutlet weak var contactCause: UITextField!
    
    @IBOutlet weak var mainLabel: UILabel!
    var count = 0
    var trackingEnabled = false
    
    
    // ---------------------------------------------------------------------
    // UI
    // ---------------------------------------------------------------------

    
    override func viewDidLoad() {
        //Set up necessary location manager handling
        super.viewDidLoad()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        locManager.requestAlwaysAuthorization()
        //Dismiss keyboard by tapping off of it
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
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
        trackingEnabled = true
        postJSON(message: getContactInfo(),
                 suffix: "contact-info")
        postJSON(message: getLatLong(),
                 suffix: "location")
        notifyContactOfMonitoring()
        createHeartRateTimer()
    }
    
    func notifyContactOfMonitoring(){
        let json: [String: Any] = ["start-monitoring": "start-monitoring"]
        postJSON(message: json, suffix: "start-monitoring")
    }
    
 
    // ---------------------------------------------------------------------
    // Heart rate
    // ---------------------------------------------------------------------
    
    func createHeartRateTimer() {
        heartRateTimer.invalidate()
        heartRateTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                     target: self,
                                     selector: #selector(getAndPostHeartRate),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func getAndPostHeartRate(){
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        var cvsDict: [String: Any] = [:]
        if (HKHealthStore.isHealthDataAvailable()){
            self.healthStore.requestAuthorization(toShare: nil, read:[heartRateType], completion:{(success, error) in
                let sortByTime = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending:false)
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "hh:mm:ss"
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY"
                
                let query = HKSampleQuery(sampleType:heartRateType, predicate:nil, limit:1, sortDescriptors:[sortByTime], resultsHandler:{(query, results, error) in
                    guard let results = results else { return }
                    for quantitySample in results {
                        let quantity = (quantitySample as! HKQuantitySample).quantity
                        let time = timeFormatter.string(from: quantitySample.startDate)
                        let date = dateFormatter.string(from: quantitySample.startDate)
                        let heartRateUnit = HKUnit(from: "count/min")
                        let heartRate = quantity.doubleValue(for: heartRateUnit)
                        cvsDict = ["time": time, "date": date, "heart_rate": heartRate]
                        self.postJSON(message: cvsDict, suffix: "hr")
                    }
                })
                self.healthStore.execute(query)
            })
        }
    }
    
    
    // ---------------------------------------------------------------------
    // Location
    // ---------------------------------------------------------------------
    
    func getLatLong() -> [String: Any] {
        let currentLocation = locManager.location
        let longitude_numeric = NSNumber(value: currentLocation!.coordinate.longitude)
        let latitude_numeric = NSNumber(value: currentLocation!.coordinate.latitude)
        let longitude = longitude_numeric.stringValue
        let latitude = latitude_numeric.stringValue
        return ["latitude": latitude, "longitude": longitude]
    }

    
    // TODO: what does this do?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Get first location (most recent, relevant one) whenever location is updated
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
    // HTTP requests
    // ---------------------------------------------------------------------


    func postJSON(message: [String: Any], suffix: String){
        //Set up request format for interacting with Python server
        var request = URLRequest(url: URL(string: "http://192.168.43.94:5000/"+suffix)!)
        request.httpMethod = "POST"
        let postedJSON = try? JSONSerialization.data(withJSONObject: message)
        request.httpBody = postedJSON
        
        //Run task that calls the actual POST

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            //check for networking errors
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            //check for http errors
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
               print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            
            
            // if kill, check for false positive
            if(responseString=="Overdose." || responseString=="Fake kill."){
                self.inDanger = true
                self.confirmNotFalsePositive()
            }
        }
        task.resume()
    }
    
    
    // ---------------------------------------------------------------------
    // Kill/overdose
    // ---------------------------------------------------------------------
    
    func confirmNotFalsePositive() {
        let alertController = UIAlertController(title: "Are you ok?",
                                                message:"We will contact your emergency contact with your location if you don't respond in the next 30 seconds",
                                                preferredStyle: .alert)
        
        let action = UIAlertAction(title: "I am ok",
                                   style: .default,
                                   handler: self.markInDangerFalse)
        alertController.addAction(action)
        DispatchQueue.main.async {
            self.present(alertController,
                         animated: true,
                         completion: nil)
            _ = Timer.scheduledTimer(timeInterval: 30.0,
                                     target: self,
                                     selector: #selector(self.triggerMasterKill),
                                     userInfo: nil,
                                     repeats: false)
        }
        
    }

    
    func markInDangerFalse(alert: UIAlertAction!){
        inDanger = false
    }
    
    
    func triggerMasterKill(){
        if(inDanger==true){
            let json: [String: Any] = ["master-kill": "master-kill"]
            self.postJSON(message: json, suffix: "master-kill")
        }
    }

    
    @IBAction func kill(_ sender: UIButton) {
        if(trackingEnabled==true) {
            //Send POST that server knows is a fake kill
            //For demonstration purposes, pretend HR is -1
            let json: [String: Any] = ["heart_rate": "-1"]
            postJSON(message: json, suffix: "fake-kill")
        } else {
            trackingEnabled = false
        }
    }
    
    
    // ---------------------------------------------------------------------
    // Stop monitoring
    // ---------------------------------------------------------------------
    
    @IBAction func stopMonitoring(_ sender: UIButton) {
        if(trackingEnabled==true){
            //Stop updating of Heart Rate
            heartRateTimer.invalidate()
            //Tell server to Stop
            let json: [String: Any] = ["stop": "stop"]
            postJSON(message: json, suffix: "stop-app")
        }else{
            trackingEnabled = false
        }
    }
    
    func stopHeartRateTimer(){
        heartRateTimer.invalidate()
    }
    

}

