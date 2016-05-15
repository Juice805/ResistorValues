//
//  extensions.swift
//  Resistor
//
//  Created by Justin Oroz on 5/14/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import Foundation

extension String {
    
    func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
        let disallowedCharacterSet = NSCharacterSet(charactersInString: matchCharacters).invertedSet
        return self.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
    }
    
    // Returns true if the string has at least one character in common with matchCharacters.
    func containsCharactersIn(matchCharacters: String) -> Bool {
        let characterSet = NSCharacterSet(charactersInString: matchCharacters)
        return self.rangeOfCharacterFromSet(characterSet) != nil
    }
    
    // Returns count of characters matching inputed string
    func countCharactersIn(matchCharacters: String) -> Int {
        let characterSet = NSCharacterSet(charactersInString: matchCharacters)
        return self.componentsSeparatedByCharactersInSet(characterSet).count - 1
    }
    
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}