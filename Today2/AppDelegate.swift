//
//  AppDelegate.swift
//  Today
//
//  Created by Gary Herman on 6/2/15.
//  Copyright (c) 2015 geeherman. All rights reserved.
//

import UIKit
import WatchKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    var window: UIWindow?
    
    var locationHelper : LocationHelper?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]?) -> Void)) {
        if let infoDictionary = userInfo as? [String: String], message = infoDictionary["message"] {
            var response = ""
            if message == "location" {
                response += "The weather is great"
                locationHelper = LocationHelper()
                locationHelper!.start()
            }
            else if message == "entry" {
                let mood = infoDictionary["mood"]
                let blurb = infoDictionary["blurb"]
                let entry = DiaryEntry()
                entry.blurb = blurb
                entry.mood = Double((mood! as NSString).integerValue) * 0.1
                entry.entryDate = NSDate()
                entry.location = locationHelper!.locationString
                entry.temperature = locationHelper!.tempString
                entry.weather = locationHelper!.weatherString
                entry.weatherIcon = locationHelper!.weatherIconURL
                entry.coordinates = locationHelper!.coord
                
                let cloudKitHelper = CloudKitHelper()
                cloudKitHelper.saveRecord(entry)
                response += "updated cloudkit diary: \(entry.blurb!), \(entry.mood), \(entry.location)"
            }
            let responseDictionary = ["message" : response]
            reply(responseDictionary)
        }
    }
}

