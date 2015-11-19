//
//  WriteViewController.swift
//  Today
//
//  Created by Gary Herman on 6/4/15.
//  Copyright (c) 2015 geeherman. All rights reserved.
//

import UIKit

class WriteViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationHelperDelegate, HealthHelperDelegate, UIActionSheetDelegate {

    @IBOutlet weak var writeView : WriteView!
    
    var PageIndex : Int = 0

    let imagePicker = UIImagePickerController()
    var photoURL: NSURL?
    
    var locationHelper = LocationHelper()
    var healthHelper = HealthHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the location, and the local weather
        locationHelper.delegate = self
        locationHelper.start()
        
        healthHelper.delegate = self
        
        writeView.setup()
        imagePicker.delegate = self
        
        writeView.blurbView.text = ""

        writeView.entryPhoto.image = UIImage(named: "tapImage.png")
    }
    
    override func viewWillAppear(animated: Bool) {
        let eventsHelper = EventHelper()
        writeView.eventsLabel.text = eventsHelper.getEvents(NSDate())
        healthHelper.getHealth(NSDate())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func publish() {
        print("publish!", terminator: "\n")
        let entry = DiaryEntry()
        entry.blurb = writeView.blurbView.text
        entry.mood = Double(writeView.MoodSlider.value)
        entry.location = writeView.locationLabel.text!
        entry.temperature = writeView.tempLabel.text!
        entry.weather = writeView.weatherLabel.text!
        entry.weatherIcon = locationHelper.weatherIconURL!
        entry.coordinates = locationHelper.coord!
        entry.photoURL = photoURL
        if photoURL != nil {
            entry.image = writeView.entryPhoto.image
            writeView.entryPhoto.image = nil
        }
        print(entry.description, terminator: "\n")
        
        let mainViewController = self.parentViewController?.parentViewController as! ViewController
        mainViewController.entries.append(entry)
        mainViewController.cloudKitHelper!.saveRecord(entry)

        writeView.publishButton.hidden = true
        
        if (mainViewController.entries.count == 1)
        {
            writeView.numEntriesLabel.text = "Congrats! Swipe right to see your first entry"
        }
        else
        {
            writeView.numEntriesLabel.text = "\(mainViewController.entries.count) entries"
        }
        
        writeView.blurbView.text = ""
        
        print("diary now has \(mainViewController.entries.count) entries", terminator: "\n")
        mainViewController.entryIndex = mainViewController.entries.count
    }
    
    // location and weather info has come in, update the UI
    func locationWeatherUpdated() {
        self.writeView.locationLabel.text = locationHelper.locationString
        self.writeView.weatherLabel.text = locationHelper.weatherString
        self.writeView.tempLabel.text = locationHelper.tempString
        let mainViewController = self.parentViewController?.parentViewController as! ViewController
        mainViewController.loadWeatherIcon(locationHelper.weatherIconURL!, toView: self.writeView)
    }
    
    func countMessage( count : Int ) {
        if ( count == 0 ) {
            writeView.numEntriesLabel.text = "This diary is empty, tell me how you feel!"
            writeView.swipeLabel.hidden = true
        }
        else if ( count == 1 ) {
            writeView.numEntriesLabel.text = "\(count) entry"
            writeView.swipeLabel.hidden = false
            writeView.swipeLabel.text = "swipe ->"
        }
        else {
            writeView.numEntriesLabel.text = "\(count) entries"
            writeView.swipeLabel.hidden = false
            writeView.swipeLabel.text = "swipe ->"
        }
    }
    
    @IBAction func addPhoto() {
        print("add photo?", terminator:"\n")
        
        let alertController = UIAlertController(title: "Add A Photo", message: "Choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        alertController.addAction(cancelAction)
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Take Picture", style: .Default) { action -> Void in
            self.showImagePicker( UIImagePickerControllerSourceType.Camera )
        }
        alertController.addAction(takePictureAction)
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Choose From Camera Roll", style: .Default) { action -> Void in
            self.showImagePicker( UIImagePickerControllerSourceType.PhotoLibrary )
        }
        alertController.addAction(choosePictureAction)

        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dispatch_async(dispatch_get_main_queue()) {
                self.writeView.entryPhoto.contentMode = .ScaleAspectFit
                self.writeView.entryPhoto.image = pickedImage
            }
            self.photoURL = self.saveImageToFile(pickedImage)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func  showImagePicker( type: UIImagePickerControllerSourceType  ) {
        print("show image picker!")
        imagePicker.sourceType = type
        imagePicker.allowsEditing = false
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func MoodChanged(sender: UISlider) {
        let smiliness = Double((sender.value * 2) - 1)
        print("smiliness \(smiliness) ")
        writeView.face.smiliness = smiliness
    }
    
    func doneWithBlurb() {
        writeView.blurbView.resignFirstResponder()
        if ( writeView.blurbView.text.characters.count > 0 ) {
            writeView.publishButton.hidden = false
        }
    }
    
    func saveImageToFile(image: UIImage) -> NSURL {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir: AnyObject = dirPaths[0]
        let filePath = docsDir.stringByAppendingPathComponent("currentImage.png")
        let newSize : CGSize = writeView.entryPhoto.frame.size
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1);
        CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), CGInterpolationQuality.High);
        image.drawInRect(CGRectMake(0,0,newSize.width,newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        UIImagePNGRepresentation(newImage)!.writeToFile(filePath, atomically: true)
        return NSURL.fileURLWithPath(filePath)
    }
    
    func healthStepsUpdated() {
        writeView.stepsCountLabel.text = String(format:"%d",healthHelper.steps)
    }
    
    func healthFlightsUpdated() {
        writeView.flightsCountLabel.text = String(format:"%d",healthHelper.flights)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let thetouch = touches.first {
            let position = thetouch.locationInView(self.view)
            if !CGRectContainsPoint(writeView.blurbView.frame, position) {
                doneWithBlurb()
            }
        }
    }


}
