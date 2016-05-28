//
//  MainView.swift
//  Resistor
//
//  Created by Justin Oroz on 5/13/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit
import AVFoundation
import iAd

class MainView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    let valueStipe = [UIColor.blackColor(), UIColor.brownColor(), UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.grayColor(), UIColor.whiteColor(), UIColor(patternImage: UIImage(named: "gold")!), UIColor(patternImage: UIImage(named: "silver")!)]
    let toleranceStipe = [UIColor(red:0.87, green:0.85, blue:0.73, alpha:1.0), UIColor(patternImage: UIImage(named: "silver")!), UIColor(patternImage: UIImage(named: "gold")!), UIColor.redColor(), UIColor.brownColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.grayColor()]
    
    @IBOutlet weak var ResistorImage: UIImageView!
        
    @IBOutlet weak var toleranceLabel: UILabel!

    @IBOutlet weak var resistancePicker: ResistancePicker!
    
    @IBOutlet weak var resistanceField: LongPressTextField!
    
    @IBOutlet weak var invisPickerButton: UIButton!
    
    @IBOutlet weak var invisEditButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        resistancePicker.selectRow(2, inComponent: 5, animated: false)
                
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
            return 0.15 * self.view.bounds.width
        case 2: //spacer
            return 0.035 * self.view.bounds.width
        case 1, 3, 4, 5: // 2-4 stripes
            return 0.1 * self.view.bounds.width
        case 6: //spacer
            return 0.25 * self.view.bounds.width
        default:
            return 0 * self.view.bounds.width
        }
    }
    
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        switch component {
        case 1: // first stripe
            return 0.46 * self.view.bounds.width
        case 3, 4, 5: // 2-4 stripes
            return 0.46 * self.view.bounds.width
        default:
            return 0
        }
        
    }
    
    
    //returns view containing item in picker
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let barWidth = self.view.bounds.width * 0.07
        
        var frame: CGRect
        
        switch component {
        case 1:
            let barHeight = self.view.bounds.width * 0.318
            
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
        case 1, 3, 4:
            return valueStipe[colorCode]
        case 5:
            return toleranceStipe[colorCode]
        default:
            return UIColor()
        }
        
    }
    
    // UIPickerViewDataSource protocol functions
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 7
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 1:
            return 9
        case 3:
            return 10
        case 4:
            return 12
        case 5:
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
        
        resistance += Double(bandOne) * 10
        
        resistance += Double(bandTwo)
        
        if bandThree < 10 {
            resistance *= pow(10, Double(bandThree))
        } else {
            resistance *= pow(10, 9 - Double(bandThree))
        }
        
        
        let prefix = ["", "k", "M", "G"]
        
        var count = 0
        while resistance >= pow(10.0, 3.0) {
            resistance /= pow(10.0, 3.0)
            count += 1
        }
        
        if (bandThree > 10) {
            resistanceField.text = "\(resistance.format(".2"))" + prefix[count] + "Ω"
        } else if (resistance < 10) {
            resistanceField.text = "\(resistance.format(".1"))" + prefix[count] + "Ω"
        } else {
            resistanceField.text = "\(resistance.format(".0"))" + prefix[count] + "Ω"
        }
        
        
        let toleranceValue = [ 20.0, 10.0, 5.0, 2.0, 1.0, 0.5, 0.25, 0.1, 0.05 ]
        
        toleranceLabel.text = "± \(toleranceValue[bandFour])% Tolerance"
        
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
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alert.addAction(OKAction)
        
        if enteredText.containsOnlyCharactersIn(allowedCharacters) {
            
            let newString = enteredText.stringByReplacingOccurrencesOfString("Ω", withString: "").stringByReplacingOccurrencesOfString("ω", withString: "")
            
            if (newString.countCharactersIn("KkGgMm") == 0) {
                
                //no unit specified
                var number = Double.init(newString)
                
                if (number == nil) {
                    self.presentViewController(alert, animated: true) {}
                    calculateResistance()
                    return
                }
                
                var count = 0
                
                while (number >= 10) {
                    number! /= 10
                    count += 1
                }
                
                if count > 10 {
                    alert.title = "Too Large"
                    dismissKeyboard(self)
                    self.presentViewController(alert, animated: true) {}
                    count = 10
                } else if ( number < 0.1 ) {
                    alert.title = "Too Small"
                    dismissKeyboard(self)
                    self.presentViewController(alert, animated: true) {}
                    number = 0.1
                }
                
                if count == 0 {
                    if number >= 1 {
                        resistancePicker.selectRow(10, inComponent: 4, animated: true)
                    } else {
                        resistancePicker.selectRow(11, inComponent: 4, animated: true)
                    }
                } else {
                    resistancePicker.selectRow(count-1, inComponent: 4, animated: true)
                }
                
                
                
                if number == 10 {
                    resistancePicker.selectRow(0, inComponent: 2, animated: true)
                    resistancePicker.selectRow(0, inComponent: 3, animated: true)
                } else if number < 1 {
                    number! *= 100
                    resistancePicker.selectRow(Int(number!/10)-1, inComponent: 1, animated: true)
                    resistancePicker.selectRow(Int(round(number!%10)), inComponent: 3, animated: true)
                } else {
                    number! *= 10
                    resistancePicker.selectRow(Int(number!/10)-1, inComponent: 1, animated: true)
                    resistancePicker.selectRow(Int(round(number!%10)), inComponent: 3, animated: true)
                }
                
                
            } else if (newString.countCharactersIn("KkGgMm") == 1 && newString.substringFromIndex(newString.endIndex.predecessor()).containsOnlyCharactersIn("KkGgMm")) {
                
                var count = 0
                var exp = 0
                
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
                    break
                }
                
                var number = Double.init(newString.substringToIndex(newString.endIndex.predecessor()))
                
                if (number == nil) {
                    self.presentViewController(alert, animated: true) {}
                    calculateResistance()
                    return
                } else {
                    number! *= pow(10.0, Double(exp))
                }
                                
                while (number >= 10) {
                    number! /= 10
                    count += 1
                }
                
                if count > 10 {
                    alert.title = "Too Large"
                    self.presentViewController(alert, animated: true) {}
                    count = 10
                } else if ( number! < 0.1 ) {
                    alert.title = "Too Small"
                    self.presentViewController(alert, animated: true) {}
                    number! = 0.1
                }
                
                if count == 0 {
                    if number! >= 1 {
                        resistancePicker.selectRow(10, inComponent: 4, animated: true)
                    } else {
                        resistancePicker.selectRow(11, inComponent: 4, animated: true)
                    }
                } else {
                    resistancePicker.selectRow(count-1, inComponent: 4, animated: true)
                }
                
                if number! == 10 {
                    resistancePicker.selectRow(0, inComponent: 2, animated: true)
                    resistancePicker.selectRow(0, inComponent: 3, animated: true)
                } else if number! < 1 {
                    number! *= 100
                    resistancePicker.selectRow(Int(number!/10)-1, inComponent: 1, animated: true)
                    resistancePicker.selectRow(Int(round(number!%10)), inComponent: 3, animated: true)
                } else {
                    number! *= 10
                    resistancePicker.selectRow(Int(number!/10)-1, inComponent: 1, animated: true)
                    resistancePicker.selectRow(Int(round(number!%10)), inComponent: 3, animated: true)
                }
                
            } else {
                dismissKeyboard(self)
                self.presentViewController(alert, animated: true) {}
            }
            
        } else {
            dismissKeyboard(self)
            self.presentViewController(alert, animated: true) {}
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
