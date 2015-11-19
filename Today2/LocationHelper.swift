//
//  LocationHelper.swift
//  Today
//
//  Created by Gary Herman on 6/6/15.
//  Copyright (c) 2015 geeherman. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationHelperDelegate {
    func locationWeatherUpdated()
}

class LocationHelper: NSObject, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    var locationFixAchieved : Bool = false
    var coord : CLLocation?
    var weatherIconURL : String?
    var locationString : String?
    var tempString : String?
    var weatherString : String?
    
    var delegate : LocationHelperDelegate?
    
    func start() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestAlwaysAuthorization()
        } else if ( CLLocationManager.authorizationStatus() == .AuthorizedAlways ) {
            print("lets get the location", terminator: "\n")
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedAlways {
            print("start updating location", terminator:"\n")
            manager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            let locationArray = locations as NSArray
            let locationObj = locationArray.lastObject as! CLLocation
            coord = locationObj
            print("lat \(coord!.coordinate.latitude)", terminator: "\n")
            print("lon \(coord!.coordinate.longitude)", terminator: "\n")
            getWeather()
        }
    }
    
    // use wunderground's public API to get the user's local current weather
    func getWeather() {
        let urlString = "http://api.wunderground.com/api/47c4fce66ab84cb3/conditions/bestfct:1/q/\(coord!.coordinate.latitude),\(coord!.coordinate.longitude).json"
        print(urlString, terminator: "\n")
        let url: NSURL = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let json: NSDictionary = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary {
                if let observation = json["current_observation"] as? NSDictionary {
                    if let weather_location = observation["display_location"] as? NSDictionary {
                        if let display_location = weather_location["full"] as? String {
                            self.locationString = display_location
                        }
                    }
                    if let weather_string = observation["weather"] as? String {
                        self.weatherString = weather_string
                    }
                    if let temp_string = observation["temperature_string"] as? String {
                        self.tempString = temp_string
                    }
                    if let icon_url = observation["icon_url"] as? String {
                        self.weatherIconURL = icon_url
                    }
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.delegate!.locationWeatherUpdated()
                        }
                    }
                    
                }
            }
        })
        task.resume()
    }

}
