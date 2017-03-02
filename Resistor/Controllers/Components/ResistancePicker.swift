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
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if let color = selectorColor
        {
            if subview.bounds.height < 1.0
            {
                subview.backgroundColor = color
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resignFirstResponder()
        self.endEditing(true)
    }
    
    
    
}
