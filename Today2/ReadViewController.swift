//
//  ReadViewController.swift
//  Today
//
//  Created by Gary Herman on 6/4/15.
//  Copyright (c) 2015 geeherman. All rights reserved.
//

import UIKit

class ReadViewController: UIViewController, HealthHelperDelegate {

    @IBOutlet weak var readView : ReadView!
    
    var PageIndex : Int = -1
    
    var theEntry : DiaryEntry?
    var numEntries: Int = 0
    let healthHelper = HealthHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup(theEntry!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup(entry: DiaryEntry) {
        readView.blurbView.layer.borderWidth = 1
        readView.blurbView.layer.borderColor = UIColor.blueColor().CGColor
        readView.blurbView.layer.shadowOffset = CGSizeMake(1, 1)
        readView.blurbView.layer.shadowOpacity = 0.5
        
        readView.locationLabel.text = entry.location
        readView.tempLabel.text = entry.temperature
        readView.weatherLabel.text = entry.weather
        readView.moodLabel.text = String(format:"%02f",entry.mood * 10)
        readView.face.smiliness = (entry.mood * 2) - 1
        readView.blurbView.text = entry.blurb
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        let str = dateFormatter.stringFromDate(entry.entryDate)
        readView.dateLabel.text = str
//        println("loaded read view with entry: \(entry.description)")
        readView.numEntriesLabel.text = "entry \(PageIndex + 1)/\(numEntries)"
        if theEntry?.weatherIcon != nil {
            self.loadWeatherIcon(theEntry!.weatherIcon!)
        }
        if entry.image != nil {
            readView.photo.image = entry.image
        }
        
        let eventsHelper = EventHelper()
        readView.eventsLabel.text = eventsHelper.getEvents(theEntry!.entryDate)
        
        healthHelper.delegate = self
        healthHelper.getHealth(theEntry!.entryDate)
    }

    func loadWeatherIcon(icon_url:String) {
        print("loading icon \(icon_url)", terminator:"\n")
        let url: NSURL = NSURL(string: icon_url)!
        let imgRequest: NSURLRequest = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(imgRequest, completionHandler: {data, response, error -> Void in
            let image = UIImage(data: data!)
            dispatch_async(dispatch_get_main_queue(), {
                print("readview loading weather icon", terminator:"\n")
                self.readView.weatherIcon.image = image
            })})
        task.resume()
    }
    
    @IBAction func jumpToWritePage() {
        if let parentVC = self.parentViewController {
            if let mainViewController = parentVC.parentViewController as? ViewController {
                mainViewController.jumpToWritePage()
            }
        }
    }

    func healthStepsUpdated() {
        readView.stepsCountLabel.text = String(format:"%d",healthHelper.steps)
    }
    
    func healthFlightsUpdated() {
        readView.flightsCountLabel.text = String(format:"%d",healthHelper.flights)
    }
}
