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

    var monitoringActivated = false
    
    var locationManager = CLLocationManager()
    var location = CLLocation()
    let healthStore = HKHealthStore()
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
        postJSON(json: getContactInfo(),
                 suffix: "contact-info")
        postJSON(json: getLatLong(),
                 suffix: "location")
        notifyContactOfMonitoring()
        createHeartRateTimer()
    }
    
    func notifyContactOfMonitoring(){
        let json: [String: Any] = ["start-monitoring": "start-monitoring"]
        postJSON(json: json, suffix: "start-monitoring")
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
                        self.postJSON(json: cvsDict, suffix: "hr")
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
    // HTTP requests
    // ---------------------------------------------------------------------


    func postJSON(json: [String: Any], suffix: String){
        let request = setupRequest(json: json, suffix: suffix)
        sendRequest(request: request)
    }
    
    func setupRequest(json: [String: Any], suffix: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "http://192.168.43.94:5000/"+suffix)!)
        request.httpMethod = "POST"
        let postedJSON = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = postedJSON
        return request
    }
    
    func sendRequest(request: URLRequest) {
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
            // get response string
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            // check response string for overdose
            self.interpretResponseStringToTriggerKill(responseString: responseString!)
        }
        task.resume()

    }
    
    func interpretResponseStringToTriggerKill(responseString: String) {
        if(responseString=="Overdose."){
            if (self.confirmInDanger()) {
                self.triggerMasterKill()
            }
        }
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
        self.postJSON(json: json, suffix: "master-kill")
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
        postJSON(json: json, suffix: "stop-app")
    }

}

