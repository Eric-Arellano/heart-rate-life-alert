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
    var timer = Timer()
    var counter = 0
    
    @IBOutlet weak var contactPreference: UISwitch!
    @IBOutlet weak var emergencyName: UITextField!
    @IBOutlet weak var emergencyNumber: UITextField!
    @IBOutlet weak var contactCause: UITextField!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    //Called with every press of main button
    @IBAction func startMonitor(_ sender: UIButton) {
        //Post current filled out contact info
        postContact()
        //Post lat long coordinates
        sendLatLongRequest()
        //Create Timer
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @IBAction func stopMonitoring(_ sender: UIButton) {
        //Stop updating of Heart Rate
        timer.invalidate()
        //Tell server to Stop
        let json: [String: Any] = ["stop": "stop"]
        makeRequest(message: json, suffix: "stop")
    }
    
    @IBAction func kill(_ sender: UIButton) {
        let json: [String: Any] = ["heart_rate": "1"]
        makeRequest(message: json, suffix: "fake_kill")
    }
    
    override func viewDidLoad() {
        //Set up necessary location manager handling
        super.viewDidLoad()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        locManager.requestAlwaysAuthorization()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func timerAction(){
        //Get heart rate, post to Python Server
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
                        self.makeRequest(message: cvsDict, suffix: "hr")
                    }
                })
                self.healthStore.execute(query)
            })
        }
    }
    
    func sendLatLongRequest(){
        //Get location -> convert that to numbers -> then to String for passing to POST
        let currentLocation = locManager.location
        let longitude_numeric = NSNumber(value: currentLocation!.coordinate.longitude)
        let latitude_numeric = NSNumber(value: currentLocation!.coordinate.latitude)
        let longitude = longitude_numeric.stringValue
        let latitude = latitude_numeric.stringValue
        
        //Make the actual request
        let json: [String: Any] = ["latitude": latitude, "longitude": longitude]
        makeRequest(message: json, suffix: "location")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Get first location (most recent, relevant one) whenever location is updated
        location = locations[0]
    }
    
    func postContact(){
        let name = emergencyName.text
        let number = emergencyNumber.text
        let cause = contactCause.text
        var preference = ""
        if(contactPreference.isOn){
            preference = "text"
        }else{
            preference = "call"
        }
        let json: [String: Any] = ["contact_name": name, "contact_number": number, "contact_preference": preference, "contact_cause": cause]
        makeRequest(message: json, suffix: "contact-info")
    }

    func makeRequest(message: [String: Any], suffix: String){
        //Set up request format for interacting with Python server
        var request = URLRequest(url: URL(string: "http://192.168.43.94:5000/"+suffix)!)
        request.httpMethod = "POST"
        let postedJSON = try? JSONSerialization.data(withJSONObject: message)
        request.httpBody = postedJSON
        
        //Run task that calls the actual POST
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        task.resume()
    }
    
    func processOverdose(){
        timer.invalidate()
    }
}

