//
//  extensions.swift
//  Resistor
//
//  Created by Justin Oroz on 5/14/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import Foundation

extension String {
    
    func containsOnlyCharactersIn(_ matchCharacters: String) -> Bool {
        let disallowedCharacterSet = CharacterSet(charactersIn: matchCharacters).inverted
        return self.rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
    
    // Returns true if the string has at least one character in common with matchCharacters.
    func containsCharactersIn(_ matchCharacters: String) -> Bool {
        let characterSet = CharacterSet(charactersIn: matchCharacters)
        return self.rangeOfCharacter(from: characterSet) != nil
    }
    
    // Returns count of characters matching inputed string
    func countCharactersIn(_ matchCharacters: String) -> Int {
        let characterSet = CharacterSet(charactersIn: matchCharacters)
        return self.components(separatedBy: characterSet).count - 1
    }
    
}

extension Double {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
