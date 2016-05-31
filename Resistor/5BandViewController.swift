//
//  5BandViewController.swift
//  Resistor
//
//  Created by Justin Oroz on 5/30/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit
import AVFoundation
import iAd

class _5BandViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {
        
    let valueStripe = [UIColor.blackColor(), UIColor.brownColor(), UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.grayColor(), UIColor.whiteColor(), UIColor(patternImage: UIImage(named: "gold")!), UIColor(patternImage: UIImage(named: "silver")!)]
    let toleranceStripe = [UIColor(red:0.87, green:0.85, blue:0.73, alpha:1.0), UIColor(patternImage: UIImage(named: "silver")!), UIColor(patternImage: UIImage(named: "gold")!), UIColor.redColor(), UIColor.brownColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.grayColor()]
    
    @IBOutlet weak var ResistorImage: UIImageView!
    
    @IBOutlet weak var toleranceLabel: UILabel!
    
    @IBOutlet weak var resistancePicker: ResistancePicker!
    
    @IBOutlet weak var resistanceField: LongPressTextField!
    
    @IBOutlet weak var invisPickerButton: UIButton!
    
    @IBOutlet weak var invisEditButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        resistancePicker.selectRow(2, inComponent: 7, animated: false)
        
        calculateResistance()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShown), name: "UIKeyboardWillShowNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShown), name: "UITextFieldTextDidBeginEditingNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHidden), name: "UIKeyboardWillHideNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHidden), name: "UITextFieldTextDidEndEditingNotification", object: nil)
        
        self.view.bringSubviewToFront(invisEditButton)
        self.view.bringSubviewToFront(invisPickerButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UIPickerViewDelegate functions
    
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        switch component {
        case 0: // spacer
            return 0.2 * self.view.bounds.width
        case 2: //spacer
            return 0.035 * self.view.bounds.width
        case 6: //spacer
            return 0.037 * self.view.bounds.width
        case 1, 3, 4, 5, 7: // 2-4 stripes
            return 0.1 * self.view.bounds.width
        case 8: //spacer
            return 0.25 * self.view.bounds.width
        default:
            return 0 * self.view.bounds.width
        }
    }
    
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        switch component {
        case 1, 7: // first stripe
            return 0.4 * self.view.bounds.width
        case 3, 4, 5: // 2-4 stripes
            return 0.4 * self.view.bounds.width
        default:
            return 0
        }
        
    }
    
    
    //returns view containing item in picker
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        var barWidth = self.view.bounds.width * 0.07
        
        var frame: CGRect
        
        switch component {
        case 1:
            let barHeight = self.view.bounds.width * 0.318
            
            frame = CGRect(x: -barWidth/2, y: -barHeight/2, width: barWidth, height: barHeight)
            break
        case 7:
            let barHeight = self.view.bounds.width * 0.318
            barWidth = self.view.bounds.width * 0.06
            frame = CGRect(x: -barWidth/2, y: -barHeight/2, width: barWidth, height: barHeight)
            break
        case 3, 4, 5:
            let barHeight = self.view.bounds.width * 0.243
            
            frame = CGRect(x: -barWidth/2, y: -barHeight/2, width: barWidth, height: barHeight)
            break
        default: // return empty views for spacers
            return UIView()
        }
        
        
        let stripe = UIView(frame: frame)
        stripe.backgroundColor = getColor(component, row: row)
        return stripe
        
    }
    
    func getColor(component: Int, row: Int) -> UIColor {
        var colorCode = row
        if component == 1 {
            colorCode = row + 1
        } else {
            colorCode = row
        }
        
        switch component {
        case 1, 3, 4, 5:
            return valueStripe[colorCode]
        case 7:
            return toleranceStripe[colorCode]
        default:
            return UIColor()
        }
        
    }
    
    // UIPickerViewDataSource protocol functions
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 9
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 1:
            return 9
        case 3,4:
            return 10
        case 5:
            return 12
        case 7:
            return 9
        default:
            return 0
        }
    }
    
    
    // picked resistance
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        calculateResistance()
    }
    
    func calculateResistance(){
        
        var resistance: Double = 0
        let bandOne = resistancePicker.selectedRowInComponent(1) + 1
        let bandTwo = resistancePicker.selectedRowInComponent(3)
        let bandThree = resistancePicker.selectedRowInComponent(4)
        let bandFour = resistancePicker.selectedRowInComponent(5)
        let bandFive = resistancePicker.selectedRowInComponent(7)
        
        resistance += Double(bandOne) * 100
        
        resistance += Double(bandTwo) * 10
        
        resistance += Double(bandThree)
        
        if bandFour < 10 {
            resistance *= pow(10, Double(bandFour))
        } else {
            resistance *= pow(10, 9 - Double(bandFour))
        }
        
        
        let prefix = ["", "k", "M", "G", "T"]
        
        var count = 0
        while resistance >= pow(10.0, 3.0) {
            resistance /= pow(10.0, 3.0)
            count += 1
        }
        
        if (bandFour > 10) {
            resistanceField.text = "\(resistance.format(".2"))" + prefix[count] + "Ω"
        } else if (resistance < 10) {
            resistanceField.text = "\(resistance.format(".2"))" + prefix[count] + "Ω"
        } else if (resistance < 100) {
            resistanceField.text = "\(resistance.format(".1"))" + prefix[count] + "Ω"
        } else {
            resistanceField.text = "\(resistance.format(".0"))" + prefix[count] + "Ω"
        }
        
        
        let toleranceValue = [ 20.0, 10.0, 5.0, 2.0, 1.0, 0.5, 0.25, 0.1, 0.05 ]
        
        toleranceLabel.text = "± \(toleranceValue[bandFive])% Tolerance"
        
    }
    
    @IBAction func editResistance(sender: AnyObject) {
        resistanceField.becomeFirstResponder()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func calculateBands(sender: AnyObject) {
        
        let enteredText = resistanceField.text!.lowercaseString
        let allowedCharacters = "0123456789.KkGgMmΩω"
        
        let alert = UIAlertController(title: "Invalid Entry", message: "", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) {
            (action) in
        }
        alert.addAction(OKAction)
        
        if enteredText.containsOnlyCharactersIn(allowedCharacters) {
            
            let newString = enteredText.stringByReplacingOccurrencesOfString("Ω", withString: "").stringByReplacingOccurrencesOfString("ω", withString: "")
            
            var number: Double?
            var count = 0
            
            if (newString.countCharactersIn("KkGgMm") == 0) {
                
                //no unit specified
                number = Double.init(newString)
                
                if (number == nil) {
                    dismissKeyboard(self)
                    self.presentViewController(alert, animated: true) {}
                    return
                }
                
            } else if (newString.countCharactersIn("KkGgMm") == 1 && newString.substringFromIndex(newString.endIndex.predecessor()).containsOnlyCharactersIn("KkGgMm")) {
                
                var exp: Int
                
                let unit = newString.substringFromIndex(newString.endIndex.predecessor())
                
                switch unit {
                case "k", "K":
                    exp = 3
                    break
                case "m", "M":
                    exp = 6
                    break
                case "g", "G":
                    exp = 9
                    break
                default:
                    exp = 0
                    break
                }
                
                number = Double.init(newString.substringToIndex(newString.endIndex.predecessor()))
                
                if (number == nil) {
                    dismissKeyboard(self)
                    self.presentViewController(alert, animated: true) {}
                    return
                } else {
                    number! *= pow(10.0, Double(exp))
                }
                

            } else {
                dismissKeyboard(self)
                self.presentViewController(alert, animated: true) {}
                return
            }
            
            
            while (number >= 10) {
                number! /= 10
                count += 1
            }
            
            if count > 11 {
                alert.title = "Too Large"
                alert.message = "Maximum: 999GΩ"
                dismissKeyboard(self)
                self.presentViewController(alert, animated: true) {}
                count = 11
                return
            } else if ( number < 1.0 ) {
                alert.title = "Too Small"
                alert.message = "Minimum: 1.00Ω"
                dismissKeyboard(self)
                self.presentViewController(alert, animated: true) {}
                number = 1.0
                return
            }
            
            switch count {
            case 0:
                resistancePicker.selectRow(11, inComponent: 5, animated: true)
                break
            case 1:
                resistancePicker.selectRow(10, inComponent: 5, animated: true)
                break
            default:
                resistancePicker.selectRow(count-2, inComponent: 5, animated: true)
                break
            }
            
            
            if number == 10 {
                resistancePicker.selectRow(0, inComponent: 3, animated: true)
                resistancePicker.selectRow(0, inComponent: 4, animated: true)
            } else if number < 1 {
                number! *= 1000
                resistancePicker.selectRow(Int(number!/100)-1, inComponent: 1, animated: true)
                resistancePicker.selectRow(Int((number!%100)/10), inComponent: 3, animated: true)
                resistancePicker.selectRow(Int(round(number!%10)), inComponent: 4, animated: true)
            } else {
                number! *= 100
                resistancePicker.selectRow(Int(number!/100)-1, inComponent: 1, animated: true)
                resistancePicker.selectRow(Int((number!%100)/10), inComponent: 3, animated: true)
                resistancePicker.selectRow(Int(round(number!%10)), inComponent: 4, animated: true)
            }
            
        } else {
            dismissKeyboard(self)
            self.presentViewController(alert, animated: true) {}
            return
        }
        
    }
    
    @IBAction func revertBands(sender: AnyObject) {
        calculateResistance()
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    func keyboardHidden(){
        invisEditButton.hidden = false
        invisPickerButton.hidden = true
    }
    
    func keyboardShown(){
        invisEditButton.hidden = true
        invisPickerButton.hidden = false
    }
    
}