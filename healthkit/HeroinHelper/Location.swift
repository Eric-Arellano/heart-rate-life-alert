import Foundation

import MapKit
import CoreLocation

class Location {
    
    var locationManager = CLLocationManager()
    var location = CLLocation()
    
    func setUpLocationMangager() {
        locationManager.delegate = 
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
    }
    
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
    

}
