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
    
    @IBAction func hourSlider(_ sender: UISlider) {
        sliderLabel.text = String(format: "%.2f", sender.value)
    }
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var sliderLabel: UILabel!
    
    //Called with every press of main button
    @IBAction func shootUp(_ sender: UIButton) {
        
        //Get heart rate, post to Python Server
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        var csvString = ""
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
                        let heartRateUnit = HKUnit(from: "count/min")
                        csvString = "\(timeFormatter.string(from: quantitySample.startDate)), \(dateFormatter.string(from: quantitySample.startDate)), \(quantity.doubleValue(for: heartRateUnit))\n"
                        self.makeRequest(message: csvString)
                    }
                })
                self.healthStore.execute(query)
            })
        }
    }
    
    override func viewDidLoad() {
        //Set up necessary location manager handling
        super.viewDidLoad()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        locManager.requestAlwaysAuthorization()
    }
    
    func sendLatLongRequest(){
        //Get location -> convert that to numbers -> then to String for passing to POST
        let currentLocation = locManager.location
        let long2 = NSNumber(value: currentLocation!.coordinate.longitude)
        let lat2 = NSNumber(value: currentLocation!.coordinate.latitude)
        let long = long2.stringValue
        let lat = lat2.stringValue
        
        //Make the actual request
        makeRequest(message: (lat + ", " + long))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Get first location (most recent, relevant one) whenever location is updated
        location = locations[0]
    }
    
    func makeRequest(message: String){
        //Set up request format for interacting with Python server
        var request = URLRequest(url: URL(string: "http://192.168.43.36:5000/location")!)
        request.httpMethod = "POST"
        let postString = message
        request.httpBody = postString.data(using: .utf8)
        
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
        }
        task.resume()
    }
}

