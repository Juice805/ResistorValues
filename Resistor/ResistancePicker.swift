//
//  ResistancePicker.swift
//  Resistor
//
//  Created by Justin Oroz on 5/13/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit

class ResistancePicker: UIPickerView {
    
    @IBInspectable var selectorColor: UIColor? = nil
    
    override func didAddSubview(subview: UIView) {
        super.didAddSubview(subview)
        if let color = selectorColor
        {
            if subview.bounds.height < 1.0
            {
                subview.backgroundColor = color
            }
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        resignFirstResponder()
        self.endEditing(true)
    }
    
    
    
}
