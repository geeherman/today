//
//  EventHelper.swift
//  Today
//
//  Created by Gary Herman on 6/8/15.
//  Copyright (c) 2015 geeherman. All rights reserved.
//

import Foundation
import EventKit

class EventHelper : NSObject {
    
    func checkPermissions() {
        // connect to EventKit, ask for permissions if necessary
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(EKEntityType.Event,
            completion: {(granted: Bool, error:NSError?) in
                if !granted {
                    print("Access to calendar not granted", terminator:"\n")
                }
        })
    }
    
    func getEvents(theDate : NSDate) -> String {
        let eventStore = EKEventStore()
        let predicate = eventStore.predicateForEventsWithStartDate(theDate, endDate: theDate, calendars: nil)
        var theEvents = ""
        if let events = eventStore.eventsMatchingPredicate(predicate) as? [EKEvent] {
            for event in events as [EKEvent] {
                theEvents += "\(event.title)\n"
            }
        }
        return theEvents
    }
}

