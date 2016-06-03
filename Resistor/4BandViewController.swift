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

class _4BandViewController: UIViewController, UIGestureRecognizerDelegate {
        
    let valueStripe = [UIColor.blackColor(), UIColor.brownColor(), UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.grayColor(), UIColor.whiteColor(), UIColor(patternImage: UIImage(named: "gold")!), UIColor(patternImage: UIImage(named: "silver")!)]
    let toleranceStripe = [UIColor(red:0.87, green:0.85, blue:0.73, alpha:1.0), UIColor(patternImage: UIImage(named: "silver")!), UIColor(patternImage: UIImage(named: "gold")!), UIColor.redColor(), UIColor.brownColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.grayColor()]
    
    @IBOutlet weak var ResistorImage: UIImageView!
        
    @IBOutlet weak var toleranceLabel: UILabel!

    @IBOutlet weak var resistancePicker: ResistancePicker!
    
    @IBOutlet weak var resistanceField: LongPressTextField!
    
    @IBOutlet weak var invisPickerButton: UIButton!
    
    @IBOutlet weak var invisEditButton: UIButton!
    
    var value = "10"

    var unit = "Ω"
    
    var myKeyboard = customKeyboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        resistancePicker.selectRow(2, inComponent: Band4.Four.rawValue, animated: false)
                
        calculateResistance(pullBands())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShown), name: "UIKeyboardWillShowNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShown), name: "UITextFieldTextDidBeginEditingNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHidden), name: "UIKeyboardWillHideNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHidden), name: "UITextFieldTextDidEndEditingNotification", object: nil)

        
        self.view.bringSubviewToFront(invisEditButton)
        self.view.bringSubviewToFront(invisPickerButton)
        
        // initialize custom keyboard
        // TODO: Decide on Keyboard Height
        self.myKeyboard = customKeyboard(frame: CGRect(x: 0, y: 0, width: 0, height: self.view.frame.height * 0.45))
        self.myKeyboard.delegate = self // the view controller will be notified by the keyboard whenever a key is tapped
        
        // replace system keyboard with custom keyboard
        resistanceField.inputView = self.myKeyboard
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func pullBands() -> [Band4: Int] {
        var bands: [Band4: Int] = [:]
        
        bands[.One] = resistancePicker.selectedRowInComponent(Band4.One.rawValue) + 1
        bands[.Two] = resistancePicker.selectedRowInComponent(Band4.Two.rawValue)
        bands[.Three] = resistancePicker.selectedRowInComponent(Band4.Three.rawValue)
        bands[.Four] = resistancePicker.selectedRowInComponent(Band4.Four.rawValue)
        
        return bands
    }
    
    // calculate resistance based on bands
    func calculateResistance(bands: [Band4: Int], dryRun: Bool = false) -> String? {
        
        var resistance: Double = 0
        
        resistance += Double(bands[.One]!) * 10
        
        resistance += Double(bands[.Two]!)
        
        if bands[.Three]! < 10 {
            resistance *= pow(10, Double(bands[.Three]!))
        } else {
            resistance *= pow(10, 9 - Double(bands[.Three]!))
        }
        
        
        let prefix = ["", "K", "M", "G"]
        
        var count = 0
        while resistance >= pow(10.0, 3.0) {
            resistance /= pow(10.0, 3.0)
            count += 1
        }
        
        if (bands[.Three]! > 10) {
            let result = resistance.format(".2")
            if dryRun == true {return result}
            value = result
        } else if (resistance < 10) {
            let result = resistance.format(".1")
            if dryRun == true {return result}
            value = result
        } else {
            let result = resistance.format(".0")
            if dryRun == true {return result}
            value = result
        }
        
        unit = prefix[count] + "Ω"
        formatLabel()
        
        let toleranceValue = [ 20.0, 10.0, 5.0, 2.0, 1.0, 0.5, 0.25, 0.1, 0.05 ]
        
        toleranceLabel.text = "± \(toleranceValue[bands[.Four]!])% Tolerance"
        
        return nil
        
    }

    @IBAction func editResistance(sender: AnyObject) {
        resistanceField.becomeFirstResponder()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        keyDone()
    }
    
    
    // calculate bands based on text input
    func calculateBands(value: String, unit: String) -> [Band4: Int]? {
        
        var bandsResult: [Band4: Int] = [:]
        
        let allowedCharacters = "0123456789."
        
        let alert = UIAlertController(title: "Invalid Entry", message: "", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) {
            (action) in
        }
        alert.addAction(OKAction)
        
        if value.containsOnlyCharactersIn(allowedCharacters) {
            
            var number = Double.init(value)
            var count = 0
            
            if value == "" || value == "." || Double.init(value) == 0 || number == nil {
                return nil
            } else {
                var exp: Double

                switch unit {
                case "kΩ", "KΩ":
                    exp = 3
                    break
                case "mΩ", "MΩ":
                    exp = 6
                    break
                case "gΩ", "GΩ":
                    exp = 9
                    break
                default:
                    exp = 0
                    break
                }
                
                number! *= pow(10.0, exp)
                
                if number < 1 {
                    number! *= 100
                    number = round(number!)
                    number! /= 100
                } else if number < 10 {
                    number! *= 10
                    number = round(number!)
                    number! /= 10
                }
                
                while (number >= 10) {
                    number! /= 10
                    count += 1
                    if number < 100 && number > 10 {
                        number = round(number!)
                    }
                }
                
                if count > 10 {
                    print("Too Large: Maximum 99GΩ")
                    return nil
                } else if ( number < 0.1 ) {
                    print("Too Small: Minimum 0.10Ω")
                    return nil
                }
                
                
                if count == 0 {
                    if number >= 1 {
                        bandsResult[.Three] = 10
                    } else {
                        bandsResult[.Three] = 11
                    }
                } else {
                    bandsResult[.Three] = count-1
                }
                
                if number < 1 {
                    number! *= 100
                    number = round(number!)
                } else {
                    number! *= 10
                    number = round(number!)
                }
                
                bandsResult[.One] = Int(number!/10)-1
                bandsResult[.Two] = Int(round(number!%10))
            }
            
        } else {
            dismissKeyboard(self)
            self.presentViewController(alert, animated: true) {}
            return nil
        }
        
        return bandsResult
    }
    
    func setBands(bands: [Band4: Int]?) {
        if bands != nil {
            for band in bands! {
                resistancePicker.selectRow(band.1, inComponent: band.0.rawValue, animated: true)
            }
        }
        
        
    }
    
    @IBAction func revertBands(sender: AnyObject) {
        calculateResistance(pullBands())
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        keyDone()
    }
    
    func keyboardHidden(){
        //invisEditButton.hidden = false
        invisPickerButton.hidden = true
    }
    
    func keyboardShown(){
        //invisEditButton.hidden = true
        
        invisPickerButton.hidden = false
    }
    
}

enum Band4: Int {
    case One = 1
    case Two = 3
    case Three = 4
    case Four = 5
}

// MARK: - Custom Keyboard Methods

extension _4BandViewController: KeyboardDelegate {
    func keyDone() {
        UIView.animateWithDuration(0.5) {
            self.view.endEditing(true)
        }
        
        //resistanceField.resignFirstResponder()
    }
    
    func keyWasTapped(character: String) {
        
        let prospectiveNewValue = calculateBands(value + character, unit: unit)
        let oldValue = calculateBands(value, unit: unit)
        let decimalTester = calculateBands(value  + "9", unit: unit)
        
        if value == "" {
            if character == "0" || character == "." {
                if  calculateBands("0.9", unit: unit) != nil {
                    value.appendContentsOf("0.")
                } else {
                    self.resistanceField.shake()
                }
            } else {
                value.appendContentsOf(character)
            }
        } else if character == "." {
            if !value.containsString(".") && calculateBands(value + ".9", unit: unit) != nil {
                if oldValue == nil {
                    value.appendContentsOf(character)
                } else if oldValue! != calculateBands(value + ".9", unit: unit)! {
                    value.appendContentsOf(character)
                } else {
                    self.resistanceField.shake()
                }
            } else {
                self.resistanceField.shake()
            }
            
        } else if character == "0" && value.containsOnlyCharactersIn(".0") {
            if calculateBands(value  + "09", unit: unit) != nil && Double.init(value + "09") >= 0.001  {
                value.appendContentsOf(character)
            } else {
                self.resistanceField.shake()
            }
        } else if prospectiveNewValue == nil {
            self.resistanceField.shake()
        } else if Double.init(value + character) >= 1000000 {
            self.resistanceField.shake()
        } else if value.containsString(".") && prospectiveNewValue != nil && Double.init(value + character) >= 0.001 {
            if oldValue == nil || prospectiveNewValue! != oldValue!{
                value.appendContentsOf(character)
            } else  {
                self.resistanceField.shake()
            }
            
        } else if oldValue != nil && prospectiveNewValue! == oldValue! {
            self.resistanceField.shake()
        } else {
            value.appendContentsOf(character)
        }
        
        formatLabel()
        setBands(calculateBands(value, unit: unit))
    }
    
    func backspace() {
        if value == "0." {
            value = ""
        } else if !value.isEmpty {
            value.removeAtIndex(value.endIndex.predecessor())
        }
        formatLabel()
        setBands(calculateBands(value, unit: unit))
        if value.isEmpty {
            
        }
    }
    
    func prefix(tag: Int) {
        switch tag {
        case 1:
            unit = "Ω"
            
            if Double.init(value) < 0.1 {
                value = ""
            }
            
        case 2:
            unit = "KΩ"
            
        case 3:
            unit = "MΩ"
            
        case 4:
            unit = "GΩ"
            
        default:
            break
        }
        
        while !value.isEmpty && !value.containsOnlyCharactersIn("0.") && (calculateBands(value, unit: unit) == nil) {
            value.removeAtIndex(value.endIndex.predecessor())
        }
        
        formatLabel()
        if !value.isEmpty {
            setBands(calculateBands(value, unit: unit))
        } else {
            let grayVal = calculateResistance(pullBands(), dryRun: true)!
            if let possibleBands = calculateBands(grayVal, unit: unit) {
                setBands(possibleBands)
            } else {
                self.resistanceField.textColor = UIColor.init(red: 1.0, green: 0, blue: 0, alpha: 0.35)
            }
            
            
        }
    }
    
    func clear() {
        value = ""
        formatLabel()
    }
    
    func formatLabel() {
        self.resistanceField.text = "\(value)\(unit)"
        if !value.isEmpty {
            self.resistanceField.textColor = UIColor.blackColor()
        } else {
            self.resistanceField.text = "\(calculateResistance(pullBands(), dryRun: true)!)\(unit)"
            self.resistanceField.textColor = UIColor.lightGrayColor()
        }
        
        unitButtonHighlighting(unit)
    }
    
    func unitButtonHighlighting(unit: String) {
        self.myKeyboard.ohmButton.enabled = true
        self.myKeyboard.kiloButton.enabled = true
        self.myKeyboard.megaButton.enabled = true
        self.myKeyboard.gigaButton.enabled = true
        
        switch unit {
        case "Ω":
            self.myKeyboard.ohmButton.enabled = false
        case "KΩ", "kΩ":
            self.myKeyboard.kiloButton.enabled = false
        case "MΩ", "mΩ":
            self.myKeyboard.megaButton.enabled = false
        case "GΩ", "gΩ":
            self.myKeyboard.gigaButton.enabled = false
        default:
            break
        }
    }
    
}


// MARK: - UIPickerViewDelegate functions
extension _4BandViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        calculateResistance(pullBands())
    }
    
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
            return 0.4 * self.view.bounds.width
        case 3, 4, 5: // 2-4 stripes
            return 0.4 * self.view.bounds.width
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
            return valueStripe[colorCode]
        case 5:
            return toleranceStripe[colorCode]
        default:
            return UIColor()
        }
        
    }
}


// MARK: - UIPickerViewDataSource protocol functions

extension _4BandViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 7
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch Band4.init(rawValue: component) {
        case .One?:
            return 9
        case .Two?:
            return 10
        case .Three?:
            return 12
        case .Four?:
            return 9
        default:
            return 0
        }
    }
}


// MARK: - UITextfieldDelegate functions
extension _4BandViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        value = ""
        formatLabel()
        
        textField.selectedTextRange = textField.textRangeFromPosition(textField.beginningOfDocument, toPosition: textField.beginningOfDocument)
        
        unitButtonHighlighting(unit)
        
    }
    
}


// MARK: - Deprecated
extension _4BandViewController {
    // calculate bands based on text input

    @IBAction func deprecatedCalculateBands(sender: AnyObject)  {
        
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
            
            if count > 10 {
                alert.title = "Too Large"
                alert.message = "Maximum: 99GΩ"
                dismissKeyboard(self)
                self.presentViewController(alert, animated: true) {}
                count = 10
                return
            } else if ( number < 0.1 ) {
                alert.title = "Too Small"
                alert.message = "Minimum: 0.10Ω"
                dismissKeyboard(self)
                self.presentViewController(alert, animated: true) {}
                number = 0.1
                return
            }
            
            if count == 0 {
                if number >= 1 {
                    resistancePicker.selectRow(10, inComponent: Band4.Three.rawValue, animated: true)
                } else {
                    resistancePicker.selectRow(11, inComponent: Band4.Three.rawValue, animated: true)
                }
            } else {
                resistancePicker.selectRow(count-1, inComponent: Band4.Three.rawValue, animated: true)
            }
            
            if number < 1 {
                number! *= 100
            } else {
                number! *= 10
            }
            
            resistancePicker.selectRow(Int(number!/10)-1, inComponent: Band4.One.rawValue, animated: true)
            resistancePicker.selectRow(Int(round(number!%10)), inComponent: Band4.Two.rawValue, animated: true)
            
        } else {
            dismissKeyboard(self)
            self.presentViewController(alert, animated: true) {}
            return
        }
        
    }
    
}

