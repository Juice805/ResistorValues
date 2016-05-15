//
//  MainView.swift
//  Resistor
//
//  Created by Justin Oroz on 5/13/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit
import AVFoundation

class MainView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let valueStipe = [UIColor.blackColor(), UIColor.brownColor(), UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.grayColor(), UIColor.whiteColor(), UIColor(patternImage: UIImage(named: "gold")!), UIColor(patternImage: UIImage(named: "silver")!)]
    let toleranceStipe = [UIColor(red:0.87, green:0.85, blue:0.73, alpha:1.0), UIColor(patternImage: UIImage(named: "silver")!), UIColor(patternImage: UIImage(named: "gold")!), UIColor.redColor(), UIColor.brownColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.grayColor()]
    
    var bandOne: Int = 1
    var bandTwo: Int = 0
    var bandThree: Int = 0
    var bandFour: Int = 0
    
    @IBOutlet weak var ResistorImage: UIImageView!
    
    @IBOutlet weak var resistanceLabel: UILabel!
    
    @IBOutlet weak var toleranceLabel: UILabel!

    @IBOutlet weak var resistancePicker: ResistancePicker!
    
    var imageSize: CGRect = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageSize = AVMakeRectWithAspectRatioInsideRect(ResistorImage.image!.size, ResistorImage.frame)
        
        resistancePicker.autoresizesSubviews = true;
        resistancePicker.frame.size.height = imageSize.height
        
        calculateResistance()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UIPickerViewDelegate functions
    
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        let imageWidth = self.imageSize.width
        
        switch component {
        case 0: // spacer
            return 0.15 * imageWidth
        case 1: // first stripe
            return 0.10 * imageWidth
        case 2: //spacer
            return 0.07 * imageWidth
        case 3, 4, 5: // 2-4 stripes
            return 0.09 * imageWidth
        case 6: //spacer
            return 0.4 * imageWidth
        default:
            return 0 * imageWidth
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        let imageHeight = self.imageSize.height
        
        switch component {
        case 1: // first stripe
            return 1.2 * imageHeight
        case 3, 4, 5: // 2-4 stripes
            return 0.8 * imageHeight
        default:
            return 0
        }
        
    }
    
    
    //returns view containing item in picker
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let imageHeight = self.imageSize.height
        let imageWidth = self.imageSize.width
        
        let barWidth = imageWidth * 0.055
        
        var frame: CGRect
        
        switch component {
        case 1:
            let barHeight = imageHeight * 0.85
            
            frame = CGRect(x: -barWidth/2, y: -barHeight/2, width: barWidth, height: barHeight)
            break
        case 3, 4, 5:
            let barHeight = imageHeight * 0.64
            
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
        
        switch component {
        case 1:
            bandOne = row + 1
            break
        case 3:
            bandTwo = row
            break
        case 4:
            bandThree = row
            break
        case 5:
            bandFour = row
            break
        default:
            break
        }
        
        calculateResistance()
    }
    
    func calculateResistance(){
        
        var resistance: Double = 0
        
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
            resistanceLabel.text = "\(resistance.format(".2"))" + prefix[count] + "Ω"
        } else if (resistance < 10) {
            resistanceLabel.text = "\(resistance.format(".1"))" + prefix[count] + "Ω"
        } else {
            resistanceLabel.text = "\(resistance.format(".0"))" + prefix[count] + "Ω"
        }
        
        
        let toleranceValue = [ 20.0, 10.0, 5.0, 2.0, 1.0, 0.5, 0.25, 0.1, 0.05 ]
        
        toleranceLabel.text = "± \(toleranceValue[bandFour])% Tolerance"
        
    }


}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

