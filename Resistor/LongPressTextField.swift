//
//  LongPressTextField.swift
//  Resistor
//
//  Created by Justin Oroz on 5/14/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit

class LongPressTextField: UITextField {
    
    let insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
    
//    override func textRectForBounds(bounds: CGRect) -> CGRect {
//        return UIEdgeInsetsInsetRect(super.textRectForBounds(bounds), insets)
//    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(super.editingRectForBounds(bounds), insets)

    }
    

}
