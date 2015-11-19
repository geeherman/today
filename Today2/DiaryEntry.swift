//
//  DiaryEntry.swift
//  Today
//
//  Created by Gary Herman on 6/3/15.
//  Copyright (c) 2015 geeherman. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit
import UIKit

class DiaryEntry {
    var blurb : String?
    var entryDate : NSDate
    var mood : Double = 0
    var location: String?
    var coordinates : CLLocation?
    var weather : String?
    var temperature : String?
    var weatherIcon : String?
    var photoURL : NSURL?
    var image : UIImage?
    
    var description : String {
        get {
            var returnString = "-------- Diary Entry ---------\n"
            returnString += "blurb: \(blurb!)\n"
            returnString += "entryDate: \(entryDate)\n"
            returnString += "mood: \(mood)\n"
            returnString += "location: \(location!)\n"
            returnString += "coordinates: \(coordinates!.coordinate.latitude),\(coordinates!.coordinate.longitude)\n"
            returnString += "weather: \(weather!)\n"
            returnString += "temperature: \(temperature!)\n"
            returnString += "weatherIcon: \(weatherIcon!)\n"
            return returnString
        }
    }
    
    init() {
        entryDate = NSDate()
    }
    
    init( record: CKRecord ) {
        blurb = record.valueForKey("Blurb") as? String
        entryDate = record.objectForKey("Date") as! NSDate
        mood = record.valueForKey("Mood") as! Double
        location = record.valueForKey("Location") as? String
        coordinates = record.objectForKey("Coordinates") as? CLLocation
        weather = record.valueForKey("Weather") as? String
        temperature = record.valueForKey("Temp") as? String
        weatherIcon = record.valueForKey("WeatherIcon") as? String
        
        if let photo = record.objectForKey("photo") as? CKAsset {
            image = UIImage(contentsOfFile: photo.fileURL.path!)
        }
//        println("read DB entry \(self.description)")
    }
}