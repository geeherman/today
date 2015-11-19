//
//  WriteView.swift
//  Today
//
//  Created by Gary Herman on 6/4/15.
//  Copyright (c) 2015 geeherman. All rights reserved.
//

import UIKit

class WriteView: UIView {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var MoodSlider: UISlider!
    @IBOutlet weak var face: FaceView!
    @IBOutlet weak var blurbView: UITextView!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var numEntriesLabel: UILabel!
    @IBOutlet weak var eventsLabel: UITextView!
    @IBOutlet weak var entryPhoto: UIImageView!

    @IBOutlet weak var swipeLabel: UILabel!

    @IBOutlet weak var stepsCountLabel: UILabel!
    @IBOutlet weak var flightsCountLabel: UILabel!
    func setup() {
        print("writeview setup", terminator:"\n")
        blurbView.layer.borderWidth = 1
        blurbView.layer.borderColor = UIColor.blueColor().CGColor
        blurbView.layer.shadowOffset = CGSizeMake(1, 1)
        blurbView.layer.shadowOpacity = 0.5
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil)

        publishButton.hidden = true
        swipeLabel.text = "loading..."
        blurbView.canBecomeFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        print("keyboard will show", terminator:"\n")
    }
    
    
}
