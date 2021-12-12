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
    var totalWords  = 0
    var currentWord = String()
    
    lazy var currentLetter :String.Index  = self.currentWord.startIndex

    
    init() {
        let path = Bundle.main.path(forResource: "Words", ofType: "plist")
        wordDict = NSDictionary(contentsOfFile: path!) as! Dictionary<String, Bool>
        wordList = Array(wordDict.keys)
        totalWords = wordList.count

        setCurrentWord()
    }
    
    func setCurrentWord() {
        currentWord   = wordList[Int(arc4random_uniform(UInt32(totalWords)))]
        currentLetter = currentWord.startIndex
    }
    
    func nextLetter()->String {
        let letter = currentWord[currentLetter...currentLetter]
        
        currentLetter = currentWord.index(after: currentLetter)        
        if (currentLetter == currentWord.endIndex) {
            setCurrentWord()
        }
        
        return String(letter)
    }
    
    func wordValue(_ word : String) -> Int {
        if (wordDict[word] == nil) {
            return 0
        }
        
        var value = 0        
        word.lowercased().forEach { letter in
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
