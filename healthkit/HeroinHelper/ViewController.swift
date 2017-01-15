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
    
    @IBAction func hourSlider(_ sender: UISlider) {
        sliderLabel.text = String(format: "%.2f", sender.value)
    }
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var sliderLabel: UILabel!
    
    //Called with every press of main button
    @IBAction func shootUp(_ sender: UIButton) {
        
        //Create Timer
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        //Set up necessary location manager handling
        super.viewDidLoad()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        locManager.requestAlwaysAuthorization()
        sendLatLongRequest()
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
        let message: [String: Any] = ["latitude": latitude, "longitude": longitude]
        makeRequest(message: message, suffix: "location")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Get first location (most recent, relevant one) whenever location is updated
        location = locations[0]
    }
    
    func makeRequest(message: [String: Any], suffix: String){
        //Set up request format for interacting with Python server
        var request = URLRequest(url: URL(string: "http://192.168.43.36:5000/"+suffix)!)
        request.httpMethod = "POST"
        let postedJSON = try? JSONSerialization.data(withJSONObject: message)
        request.httpBody = postedJSON
        
        //Run task that calls the actual POST
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            //Handle networking errors
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            //Get response from server
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            if(responseString=="overdose"){
                self.processOverdose()
            }
        }
        task.resume()
    }
    
    func processOverdose(){
        timer.invalidate()
    }
}

