//
//  CloudKitHelper.swift
//  Today
//
//  Created by Gary Herman on 6/3/15.
//  Copyright (c) 2015 geeherman. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitDelegate {
//    func errorUpdating(error: NSError)
    func diaryUpdated()
}

class CloudKitHelper {
    var container : CKContainer
    var publicDB : CKDatabase
    let privateDB : CKDatabase
    var delegate : CloudKitDelegate?
    
    var diary = [DiaryEntry]()
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    func saveRecord(entry : DiaryEntry) {
        let entryRecord = CKRecord(recordType: "DiaryEntry")
        entryRecord.setValue(entry.blurb!, forKey: "Blurb")
        entryRecord.setValue(entry.mood, forKey: "Mood")
        entryRecord.setObject(entry.entryDate, forKey: "Date")
        if entry.location != nil {
            entryRecord.setValue(entry.location!, forKey: "Location")
        }
        if entry.temperature != nil {
            entryRecord.setValue(entry.temperature!, forKey: "Temp")
        }
        if entry.weather != nil {
            entryRecord.setValue(entry.weather!, forKey: "Weather")
        }
        if entry.weatherIcon != nil {
            entryRecord.setValue(entry.weatherIcon!, forKey: "WeatherIcon")
        }
        if entry.coordinates != nil {
            entryRecord.setObject(entry.coordinates!, forKey: "Coordinates")
        }
        if entry.photoURL != nil {
            let asset = CKAsset(fileURL: entry.photoURL!)
            entryRecord.setObject(asset, forKey: "photo")
        }
        
        privateDB.saveRecord(entryRecord, completionHandler: { (record, error) -> Void in
            if ( error != nil )
            {
                print("Error saving to cloud kit \(error!.description)", terminator: "\n")
            }
            else
            {
                print("Saved to cloud kit", terminator: "\n")
            }
        })
    }
    
    func getDiary() {
        print("get diary", terminator: "\n")
        let predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "Date", ascending: true)
        
        let query = CKQuery(recordType: "DiaryEntry",
            predicate:  predicate)
        query.sortDescriptors = [sort]
        
        privateDB.performQuery(query, inZoneWithID: nil) {
            results, error in
            if error != nil {
                print("error getting entries from iCloud", terminator: "\n")
                return
            } else {
                print("results : \(results!.count)", terminator: "\n")
//                var counter = 0
                for record in results! {
                    let entry = DiaryEntry(record: record)
                    self.diary.append(entry)
//                    print("added entry \(counter++)")
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate!.diaryUpdated()
                }
            }
            print("done with getDiary")
        }
    }
    
}
