//
//  customKeyboard.swift
//  Resistor
//
//  Created by Justin Oroz on 6/1/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit


// The view controller will adopt this protocol (delegate)
// and thus must contain the keyWasTapped method
protocol KeyboardDelegate: class {
    func keyWasTapped(character: String)
    func keyDone()
    func backspace()
    func prefix(tag: Int)
    func clear()
}

class customKeyboard: UIView {
    // http://stackoverflow.com/questions/33474771/a-swift-example-of-custom-views-for-data-input-custom-in-app-keyboard

    @IBOutlet weak var ohmButton: UIButton!
    @IBOutlet weak var kiloButton: UIButton!
    @IBOutlet weak var megaButton: UIButton!
    @IBOutlet weak var gigaButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    // This variable will be set as the view controller so that
    // the keyboard can send messages to the view controller.
    weak var delegate: KeyboardDelegate?
    
    // MARK:- keyboard initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    func initializeSubviews() {
        let xibFileName = "customKeyboard" // xib extention not included
        let view = NSBundle.mainBundle().loadNibNamed(xibFileName, owner: self, options: nil)[0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    // MARK:- Button actions from .xib file
    
    @IBAction func keyTapped(sender: UIButton) {
        // When a button is tapped, send that information to the
        // delegate (ie, the view controller)
        
        switch sender.tag {
        case 0, 9: //number or .
            self.delegate?.keyWasTapped(sender.titleLabel!.text!) // could alternatively send a tag value
        case 1,2,3,4:
            self.delegate?.prefix(sender.tag)
        case 99:
            self.delegate?.backspace()
        case 100:
            self.delegate?.keyDone()
        default:
            self.delegate?.keyWasTapped(sender.titleLabel!.text!) // could alternatively send a tag value
        }
        
    }
    
    @IBAction func clear(sender: AnyObject) {
        self.delegate?.clear()
        buttonReleased(deleteButton)
    }

    @IBAction func buttonTouched(sender: UIButton) {
        sender.backgroundColor = UIColor.darkGrayColor()
    }
    @IBAction func buttonReleased(sender: UIButton) {
        switch sender.tag {
        case 0:
            sender.backgroundColor = UIColor.whiteColor()
        case 99, 9:
            sender.backgroundColor = UIColor.lightTextColor()
        default:
            break
        }
    }
    
    @IBAction func unitButtonHighlighting(sender: UIButton) {
        let unitButtons = [self.ohmButton, self.kiloButton, self.megaButton, self.gigaButton]
        
        for button in unitButtons {
            button.enabled = true
            button.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        }
        
        sender.enabled = false
        sender.backgroundColor = UIColor.init(red: 163/255, green: 204/255, blue: 254/255, alpha: 1.0)
        
    }
}
