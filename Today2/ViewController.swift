//
//  ViewController.swift
//  Today
//
//  Created by Gary Herman on 6/2/15.
//  Copyright (c) 2015 geeherman. All rights reserved.
//

import UIKit
import Foundation
import HealthKit

class ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, CloudKitDelegate
{
    var entries = [DiaryEntry]()
    var entryIndex : Int = 0
    
    var cloudKitHelper : CloudKitHelper?
    var pageController: UIPageViewController?
    
    var writeViewController : WriteViewController?
    var readViewController : ReadViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the stored Diary entries
        cloudKitHelper = CloudKitHelper()
        cloudKitHelper!.delegate = self
        cloudKitHelper!.getDiary()
        
        print("setting up page controller")
        // setup the page controller with the write page as the first page
        pageController = UIPageViewController(
            transitionStyle: .PageCurl,
            navigationOrientation: .Horizontal,
            options: nil)
        pageController?.delegate = self
        pageController?.dataSource = self
        let startingViewController: WriteViewController = viewControllerAtIndex(0)! as! WriteViewController
        let viewControllers = [startingViewController]
        pageController!.setViewControllers(viewControllers,
            direction: .Forward,
            animated: false,
            completion: nil)
        self.addChildViewController(pageController!)
        self.view.addSubview(self.pageController!.view)
        //        let pageViewRect = self.view.bounds
        //        pageController!.view.frame = pageViewRect
        pageController!.didMoveToParentViewController(self)
        
        print("setting up event helper")
        let eventHelper = EventHelper()
        eventHelper.checkPermissions()
        
        
        print("setting up health kit")
        // connect to HealthKit, ask for permissions if necessary
        let healthKitStore:HKHealthStore = HKHealthStore()
        if HKHealthStore.isHealthDataAvailable() {
            let healthKitTypesToWrite : Set<HKSampleType> = []
            let healthKitTypesToRead : Set<HKSampleType> = [
                HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
                HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)!
            ]
            healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
                print("health store kit", terminator: "\n")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        if index > entries.count || index < 0 {
            return nil
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        if index == entries.count {
            if writeViewController == nil {
                writeViewController = storyBoard.instantiateViewControllerWithIdentifier("writeViewController") as? WriteViewController
            }
            return writeViewController
        } else {
            readViewController = storyBoard.instantiateViewControllerWithIdentifier("readViewController") as? ReadViewController
            readViewController!.PageIndex = index
            readViewController!.theEntry = entries[index];
            readViewController!.numEntries = entries.count
            return readViewController;
        }
    }
    
    func indexOfViewController(viewController: UIViewController) -> Int {
        if viewController == writeViewController {
            return entries.count
        }
        if let diaryPage : ReadViewController = viewController as? ReadViewController {
            return diaryPage.PageIndex
        } else {
            return NSNotFound
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController)
        if index == NSNotFound {
            return nil
        }
        if index == 0 {
            print("no more left, at last entry", terminator: "\n")
            return nil
        }
        index--
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController)
        if index == NSNotFound {
            return nil
        }
        if index == entries.count {
            print("no more right, at write page", terminator: "\n")
            return nil
        }
        index++
        return viewControllerAtIndex(index)
    }
    
    func jumpToWritePage() {
        let viewControllers = [writeViewController!]
        pageController!.setViewControllers(viewControllers,
            direction: .Forward,
            animated: true,
            completion: nil)
    }
    
    // cloudkit is done loading the diary
    func diaryUpdated() {
        entries = cloudKitHelper!.diary
        writeViewController!.countMessage(entries.count)
        entryIndex = entries.count
        print("fetched entries : \(entries.count)", terminator: "\n")
    }
    
    func loadWeatherIcon(icon_url:String, toView: UIView) {
        print("loading icon \(icon_url)", terminator: "\n")
        let url: NSURL = NSURL(string: icon_url)!
        let imgRequest: NSURLRequest = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(imgRequest, completionHandler: {data, response, error -> Void in
            let image = UIImage(data: data!)
            dispatch_async(dispatch_get_main_queue(), {
                if ( toView == self.writeViewController!.writeView )
                {
                    print("writeview loading weather icon", terminator:"\n")
                    self.writeViewController!.writeView.weatherIcon.image = image
                }
                else if ( self.readViewController != nil )
                {
                    self.readViewController!.readView.weatherIcon.image = image
                }
            })})
        task.resume()
    }
    
}

