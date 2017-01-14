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
    
    @IBAction func shootUp(_ sender: UIButton) {
        mainLabel.text = "Test"
        locManager.requestAlwaysAuthorization()
        let currentLocation = locManager.location
        let long2 = NSNumber(value: currentLocation!.coordinate.longitude)
        let lat2 = NSNumber(value: currentLocation!.coordinate.latitude)
        let long = long2.stringValue
        let lat = lat2.stringValue
        mainLabel.text = long
        
        makeRequest(message: (lat + ", " + long))
        
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
                        print(csvString)
                        //print("\(timeFormatter.string(from: quantitySample.startDate)),\(dateFormatter.string(from: quantitySample.startDate)),\(quantity.doubleValue(for: heartRateUnit))")

                        self.makeRequest(message: csvString)
                    }
                })
                self.healthStore.execute(query)
            })
 
        }
        makeRequest(message: "test")
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations[0]
    }
    
    func makeRequest(message: String){
        var request = URLRequest(url: URL(string: "http://192.168.43.36:5000/location")!)
        request.httpMethod = "POST"
        let postString = message
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
}

