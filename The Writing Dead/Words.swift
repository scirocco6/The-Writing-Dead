//
//  Words.swift
//  Puzzle Zombies
//
//  Created by six on 6/24/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import Foundation

class Words {
    var wordDict    = Dictionary<String, Bool>()
    var wordList    = Array<String>()
    let totalWords  = 0
    var currentWord = String()
    
    @lazy var currentLetter :String.Index  = self.currentWord.startIndex

    
    init() {
        let path = NSBundle.mainBundle().pathForResource("Words", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path)
        
        for key : AnyObject in dict.allKeys {
            let stringKey : String = key as String
            let keyValue : Bool = dict.valueForKey(stringKey) as Bool
            
            wordDict[stringKey] = keyValue
            wordList += stringKey
            totalWords++
        }
        setCurrentWord()
    }
    
    func setCurrentWord() {
        currentWord   = wordList[Int(arc4random_uniform(UInt32(totalWords)))]
        currentLetter = currentWord.startIndex
    }
    
    func nextLetter()->String {
        let letter = currentWord[currentLetter..currentLetter.succ()]
        
        currentLetter = currentLetter.succ()
        if (currentLetter == currentWord.endIndex) {
            setCurrentWord()
        }
        
        return letter
    }
    
    func wordValue(word : String) -> Int? {
        if (!wordDict[word]) {
            return nil
        }
        
        var value = 0

        for letter in word.lowercaseString {
            switch (letter) {
                case "d", "g":                  value += 2
                case "b", "c", "m", "p":        value += 3
                case "f","h", "v", "w", "y":    value += 4
                case "k":                       value += 5
                case "j" , "x":                 value += 8
                case "q" , "z":                 value += 10
                default:                        value += 1
            }
        }

        return value
    }
}
