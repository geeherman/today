//
//  HealthHelper.swift
//  Today
//
//  Created by Gary Herman on 6/8/15.
//  Copyright (c) 2015 geeherman. All rights reserved.
//

import Foundation
import HealthKit

protocol HealthHelperDelegate {
    func healthStepsUpdated()
    func healthFlightsUpdated()
}

class HealthHelper : NSObject {
    
    var steps : Int = 0
    var flights : Int = 0
    
    var delegate : HealthHelperDelegate?
    
    func getHealth(theDate : NSDate) {
        let calendar = NSCalendar.currentCalendar()
        let now = theDate
        let components = calendar.components([.Year, .Month, .Day], fromDate: now)
        
        let startDate = calendar.dateFromComponents(components)
        let endDate = calendar.dateByAddingUnit(.Day, value: 1, toDate: startDate!, options: NSCalendarOptions(rawValue: 0))
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit: 0, sortDescriptors: nil) {
            query, results, error in
            
            if error != nil {
                print("An error occured fetching the user's tracked steps. In your app, try to handle this gracefully. The error was: \(error!.localizedDescription)", terminator: "\n");
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    var stepcount:Double = 0
                    for sample in results as! [HKQuantitySample] {
                        stepcount += sample.quantity.doubleValueForUnit(HKUnit.countUnit())
                    }
                    self.steps = Int(stepcount)
                    if self.delegate != nil {
                        self.delegate!.healthStepsUpdated()
                    }
                }
            }
        }
        
        let sampleType2 = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
        let predicate2 = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let query2 = HKSampleQuery(sampleType: sampleType2!, predicate: predicate2, limit: 0, sortDescriptors: nil) {
            query, results, error in
            
            if error != nil {
                print("An error occured fetching the user's tracked flights. In your app, try to handle this gracefully. The error was: \(error!.localizedDescription)", terminator: "\n");
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    var flightcount:Double = 0
                    for sample in results as! [HKQuantitySample] {
                        flightcount += sample.quantity.doubleValueForUnit(HKUnit.countUnit())
                    }
                    self.flights = Int(flightcount)
                    if self.delegate != nil {
                        self.delegate!.healthFlightsUpdated()
                    }
                }
            }
        }
        
        let healthKitStore:HKHealthStore = HKHealthStore()
        healthKitStore.executeQuery(query)
        healthKitStore.executeQuery(query2)
    }

}
