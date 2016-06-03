//
//  6BandViewController.swift
//  Resistor
//
//  Created by Justin Oroz on 5/13/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit
import AVFoundation
import iAd

class _6BandViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let valueStripe = [UIColor.blackColor(), UIColor.brownColor(), UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.grayColor(), UIColor.whiteColor(), UIColor(patternImage: UIImage(named: "gold")!), UIColor(patternImage: UIImage(named: "silver")!)]
    let toleranceStripe = [UIColor(red:0.87, green:0.85, blue:0.73, alpha:1.0), UIColor(patternImage: UIImage(named: "silver")!), UIColor(patternImage: UIImage(named: "gold")!), UIColor.redColor(), UIColor.brownColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.grayColor()]
    let tempCoefStripe = [UIColor.brownColor(), UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.blueColor(), UIColor.purpleColor()]
    
    @IBOutlet weak var ResistorImage: UIImageView!
    
    @IBOutlet weak var toleranceLabel: UILabel!
    
    @IBOutlet weak var tempCoeffLabel: UILabel!
    
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
        
        resistancePicker.selectRow(2, inComponent: Band6.Five.rawValue, animated: false)
        
        calculateResistance(pullBands())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShown), name: "UIKeyboardWillShowNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShown), name: "UITextFieldTextDidBeginEditingNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHidden), name: "UIKeyboardWillHideNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHidden), name: "UITextFieldTextDidEndEditingNotification", object: nil)
        
        
        self.view.bringSubviewToFront(invisEditButton)
        self.view.bringSubviewToFront(invisPickerButton)
        
        // initialize custom keyboard
        // TODO: Decide on Keyboard Height
        self.myKeyboard = customKeyboard(frame: CGRect(x: 0, y: 0, width: 0, height: self.view.frame.height * 0.35))
        self.myKeyboard.delegate = self // the view controller will be notified by the keyboard whenever a key is tapped
        
        // replace system keyboard with custom keyboard
        resistanceField.inputView = self.myKeyboard
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pullBands() -> [Band6: Int] {
        var bands: [Band6: Int] = [:]
        
        bands[.One] = resistancePicker.selectedRowInComponent(Band6.One.rawValue) + 1
        bands[.Two] = resistancePicker.selectedRowInComponent(Band6.Two.rawValue)
        bands[.Three] = resistancePicker.selectedRowInComponent(Band6.Three.rawValue)
        bands[.Four] = resistancePicker.selectedRowInComponent(Band6.Four.rawValue)
        bands[.Five] = resistancePicker.selectedRowInComponent(Band6.Five.rawValue)
        bands[.Six] = resistancePicker.selectedRowInComponent(Band6.Six.rawValue)
        
        return bands
    }
    
    // calculate resistance based on bands
    func calculateResistance(bands: [Band6: Int], dryRun: Bool = false) -> String? {
        
        var resistance: Double = 0
        
        resistance += Double(bands[.One]!) * 100
        
        resistance += Double(bands[.Two]!) * 10
        
        resistance += Double(bands[.Three]!)
        
        if bands[.Four]! < 10 {
            resistance *= pow(10, Double(bands[.Four]!))
        } else {
            resistance *= pow(10, 9 - Double(bands[.Four]!))
        }
        
        
        let prefix = ["", "K", "M", "G"]
        
        var count = 0
        while resistance >= pow(10.0, 3.0) {
            resistance /= pow(10.0, 3.0)
            count += 1
        }
        
        if (bands[.Four]! > 10) {
            let result = resistance.format(".2")
            if dryRun == true {return result}
            value = result
        } else if (resistance < 10) {
            let result = resistance.format(".2")
            if dryRun == true {return result}
            value = result
        } else if (resistance < 100) {
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
        
        toleranceLabel.text = "± \(toleranceValue[bands[.Five]!])% Tolerance"
        
        let tempValue = [ 100, 50, 15, 25, 10, 5 ]
        
        tempCoeffLabel.text = "Temp. Coeff: \(tempValue[bands[.Six]!])ppm/°K"
        
        return nil
        
    }
    
    @IBAction func editResistance(sender: AnyObject) {
        resistanceField.becomeFirstResponder()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        keyDone()
    }
    
    
    // calculate bands based on text input
    func calculateBands(value: String, unit: String) -> [Band6: Int]? {
        
        var bandsResult: [Band6: Int] = [:]
        
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
                    number! *= 1000
                    number = round(number!)
                    number! /= 1000
                } else if number < 10 {
                    number! *= 100
                    number = round(number!)
                    number! /= 100
                }
                
                while (number >= 10) {
                    number! /= 10
                    count += 1
                    if number < 1000 && number > 100 {
                        number = round(number!)
                    }
                }
                
                if count > 12 {
                    print("Too Large: Maximum 999GΩ")
                    return nil
                } else if ( number < 1.0 ) {
                    print("Too Small: Minimum 1.0Ω")
                    return nil
                }
                
                
                switch count {
                case 0:
                    bandsResult[.Four] = 11
                case 1:
                    bandsResult[.Four] = 10
                default:
                    bandsResult[.Four] = count-2
                }
                
                if number < 1 {
                    number! *= 1000
                    number = round(number!)
                } else {
                    number! *= 100
                    number = round(number!)
                }
                
                bandsResult[.One] = Int(number!/100)-1
                bandsResult[.Two] = Int((number!%100)/10)
                bandsResult[.Three] = Int(round(number!%10))
                
                if bandsResult[.One] >= 9 {
                    print("Too Large: Maximum 999GΩ")
                    return nil
                }
            }
            
        } else {
            dismissKeyboard(self)
            self.presentViewController(alert, animated: true) {}
            return nil
        }
        
        return bandsResult
    }
    
    func setBands(bands: [Band6: Int]?) {
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

enum Band6: Int {
    case One = 1
    case Two = 3
    case Three = 4
    case Four = 5
    case Five = 6
    case Six = 8
}

// MARK: - Custom Keyboard Methods

extension _6BandViewController: KeyboardDelegate {
    func keyDone() {
        UIView.animateWithDuration(0.35) {
            self.view.endEditing(true)
        }
        
        //resistanceField.resignFirstResponder()
    }
    
    func keyWasTapped(character: String) {
        
        let prospectiveNewValue = calculateBands(value + character, unit: unit)
        let oldValue = calculateBands(value, unit: unit)
        
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
        calculateResistance(pullBands())
        selectUnit()
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
    }
    
    func selectUnit(){
        switch unit {
        case "Ω":
            self.myKeyboard.unitButtonHighlighting(self.myKeyboard.ohmButton)
        case "kΩ", "KΩ":
            self.myKeyboard.unitButtonHighlighting(self.myKeyboard.kiloButton)
        case "mΩ", "MΩ":
            self.myKeyboard.unitButtonHighlighting(self.myKeyboard.megaButton)
        case "gΩ", "GΩ":
            self.myKeyboard.unitButtonHighlighting(self.myKeyboard.gigaButton)
        default:
            break
        }
    }
    
}


// MARK: - UIPickerViewDelegate functions
extension _6BandViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        calculateResistance(pullBands())
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        switch component {
        case 0: // spacer
            return 0.215 * self.view.bounds.width
        case 2: //spacer
            return 0.0435 * self.view.bounds.width
        case 7:
            return 0.037 * self.view.bounds.width
        case 1, 3, 4, 5, 6, 8: // stripes
            return 0.075 * self.view.bounds.width
        case 9: //spacer
            return 0.25 * self.view.bounds.width
        default:
            return 0 * self.view.bounds.width
        }
    }
    
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        switch component {
        case 1, 8: // first and last stripe
            return 0.4 * self.view.bounds.width
        case 3, 4, 5, 6: // 2-5 stripes
            return 0.4 * self.view.bounds.width
        default:
            return 0
        }
        
    }
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let barWidth = self.view.bounds.width * 0.06
        
        var frame: CGRect
        
        switch component {
        case 1,8:
            let barHeight = self.view.bounds.width * 0.318
            
            frame = CGRect(x: -barWidth/2, y: -barHeight/2, width: barWidth, height: barHeight)
            break
        case 3, 4, 5, 6:
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
        
        let band = Band6.init(rawValue: component)
        if band == .One {
            colorCode = row + 1
        } else {
            colorCode = row
        }
        
        switch band {
        case .One?, .Two?, .Three?, .Four?:
            return valueStripe[colorCode]
        case .Five?:
            return toleranceStripe[colorCode]
        case .Six?:
            return tempCoefStripe[colorCode]
        default:
            return UIColor()
        }
        
    }
}


// MARK: - UIPickerViewDataSource protocol functions

extension _6BandViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 10
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch Band6.init(rawValue: component) {
        case .One?:
            return 9
        case .Two?, .Three?:
            return 10
        case .Four?:
            return 12
        case .Five?:
            return 9
        case .Six?:
            return 6
        default:
            return 0
        }
    }
}


// MARK: - UITextfieldDelegate functions
extension _6BandViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        value = ""
        formatLabel()
        
        selectUnit()
        
        textField.selectedTextRange = textField.textRangeFromPosition(textField.beginningOfDocument, toPosition: textField.beginningOfDocument)
    }
    
}


// MARK: - Deprecated
extension _6BandViewController {
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
                resistancePicker.selectRow(11, inComponent: Band6.Four.rawValue, animated: true)
                break
            case 1:
                resistancePicker.selectRow(10, inComponent: Band6.Four.rawValue, animated: true)
                break
            default:
                resistancePicker.selectRow(count-2, inComponent: Band6.Four.rawValue, animated: true)
                break
            }
            
            
            if number < 1 {
                number! *= 1000
            } else {
                number! *= 100
            }
            
            resistancePicker.selectRow(Int(number!/100)-1, inComponent: Band6.One.rawValue, animated: true)
            resistancePicker.selectRow(Int((number!%100)/10), inComponent: Band6.Two.rawValue, animated: true)
            resistancePicker.selectRow(Int(round(number!%10)), inComponent: Band6.Three.rawValue, animated: true)
            
        } else {
            dismissKeyboard(self)
            self.presentViewController(alert, animated: true) {}
            return
        }
        
        
    }
    
}

