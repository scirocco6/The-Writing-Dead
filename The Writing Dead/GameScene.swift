//
//  GameScene.swift
//  Puzzle Zombies
//
//  Created by six on 6/23/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import SpriteKit
import QuartzCore // need this to make CIFilter work

class GameScene: SKScene, SKPhysicsContactDelegate {
    let words       = Words()
    var word        = String()
    
    let librarian   = Librarian()
    var zombieArray = Array<Zombie>()
    var catArray    = Array<Cat>()
    var shelfArray  = Array<SKSpriteNode>()
    
    var level       = 1
    var score       = 0
    var shh         = 3
    var zombieDelay = 5.0
    var gameOn      = false
    
    let backgroundTexture = SKTexture(imageNamed: "Library")
    var backGround        = SKSpriteNode()
    var showBackground    = true
    
    let titleSplash = SKSpriteNode(imageNamed: "The Writing Dead")
    let scoreBoard  = SKLabelNode(fontNamed:"Dead Font Walking")
    let shhhBoard   = SKLabelNode(fontNamed:"Dead Font Walking")
    let wordBoard   = SKLabelNode(fontNamed:"Dead Font Walking")

    let playfieldCategory = UInt32(0x01 << 0)
    let librarianCategory = UInt32(0x01 << 1)
    let zombieCategory    = UInt32(0x01 << 2)
    let catCategory       = UInt32(0x01 << 3)
    let letterCategory    = UInt32(0x01 << 4)
    let platformCategory  = UInt32(0x01 << 5)
    let titleCategory     = UInt32(0x01 << 6)
    
    @lazy var librarianHitPlayfield : UInt32 = self.librarianCategory | self.playfieldCategory
    @lazy var zombieHitPlayfield    : UInt32 = self.zombieCategory    | self.playfieldCategory
    @lazy var zombieHitLibrarian    : UInt32 = self.zombieCategory    | self.librarianCategory
    @lazy var catHitPlayfield       : UInt32 = self.catCategory       | self.playfieldCategory
    @lazy var catHitZombie          : UInt32 = self.catCategory       | self.zombieCategory
    @lazy var letterHitPlayfield    : UInt32 = self.letterCategory    | self.playfieldCategory
    @lazy var zombieHitTitle        : UInt32 = self.zombieCategory    | self.titleCategory
    
    override func didMoveToView(view: SKView) {
// playfield setup
        backGround           = SKSpriteNode(texture: backgroundTexture, size: size)
        backGround.position  = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        backGround.zPosition = -1
        addChild(backGround)
        
        titleSplash.position                      = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) + 100)
        titleSplash.physicsBody                   = SKPhysicsBody(rectangleOfSize: titleSplash.frame.size)
        titleSplash.physicsBody.affectedByGravity = false
        titleSplash.physicsBody.usesPreciseCollisionDetection = true
        addChild(titleSplash)
        
        wordBoard.fontSize = 42
        wordBoard.position = CGPointMake(CGRectGetMidX(frame), 25)
        wordBoard.text     = word
        addChild(wordBoard)
        
        scoreBoard.position = CGPointMake(10, 5)
        scoreBoard.text     = "Score: \(score)"
        scoreBoard.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        addChild(scoreBoard)
        
        shhhBoard.position = CGPointMake(890, 5)
        shhhBoard.text     = "\(shh) :shhH"
        shhhBoard.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        addChild(shhhBoard)

        physicsWorld.contactDelegate = self
        
        let newRect                 = CGRect(x: 0, y: 75, width: frame.width, height: frame.height - 75)
        physicsBody                 = SKPhysicsBody(edgeLoopFromRect: newRect)
        physicsBody.friction        = 0
        physicsBody.categoryBitMask = playfieldCategory
        
// player setup
        librarian.physicsBody.categoryBitMask = librarianCategory
        librarian.physicsBody.collisionBitMask   = playfieldCategory | zombieCategory       // touching causes event

        addZombie()
        addZombie()
    }
    
    func startGame() {
        for zombie in zombieArray { // remove all of the atract mode zombies
            zombie.removeFromParent()
        }
        
        titleSplash.removeFromParent()
        addChild(librarian)
        addZombie()
    }
    
    override func update(currentTime: CFTimeInterval) { // called BEFORE frame is rendered
        
    }
    
    func addZombie() {
        let newZombie = Zombie(letter: words.nextLetter())
        newZombie.physicsBody.categoryBitMask    = zombieCategory
        newZombie.physicsBody.contactTestBitMask = playfieldCategory | librarianCategory | zombieCategory   // touching causes event
        
        addChild(newZombie)
        
        zombieArray += newZombie
        
        if (zombieDelay > 1) {
            zombieDelay -= 0.001 // reduce the delay between new zombies.  This needs play testing badly level/bonus etc should have an effect
        }
        // wait a while then add another zombie
        runAction(SKAction.waitForDuration(zombieDelay), completion: {self.addZombie()})
    }
    
    func releaseCat() {
        println("meow!!@");
        let newCat = Cat(from: librarian.position, direction: librarian.direction)
        newCat.physicsBody.categoryBitMask    = catCategory
        newCat.physicsBody.contactTestBitMask = playfieldCategory | zombieCategory       // touching causes event
        newCat.physicsBody.collisionBitMask   = playfieldCategory | zombieCategory       // touching causes event
        
        catArray += newCat
        
        addChild(newCat)
    }
    
    func shhh() {
        if(shh == 0) {
            println("No shh for you!!@")
            return()
        }
        shh--
        shhhBoard.text     = "\(shh) :shhH"
        println("shhh happens")
        
        let shhSprite = SKSpriteNode(imageNamed: "Shh")

        shhSprite.setScale(0.1)
        shhSprite.position = backGround.position
        addChild(shhSprite)
        shhSprite.runAction(SKAction.playSoundFileNamed("shh.mp3", waitForCompletion: false))
        bigifyFadeAndVanish(shhSprite)
        
        for zombie in zombieArray {
            zombie.shhh()
        }
    }
    
    func addLetterToWord(letter: Letter) {
        letter.removeFromParent()
        
        word += letter.text
        updateWordBoard()
    }
    
    func dropLastLetter() {
        word = word[word.startIndex..word.endIndex.pred()]
        updateWordBoard()
    }
    
    func updateWordBoard() {
        wordBoard.text = word
        
        switch(words.wordValue(word)) {
        case 0:
            wordBoard.fontColor = SKColor.redColor()
        case 1...9:
            wordBoard.fontColor = SKColor.greenColor()
        case 10...49:
            wordBoard.fontColor = SKColor(red: 0.988, green: 0.851, blue: 0.459, alpha: 1.0)
        default: ()
        }
    }
    
    func scoreWord() {
        let value = words.wordValue(word)
        if (value == 0) {
            println("No \(word) for you!!@")
            return()
        }
        
        println("\(word) is a yummy \(word)")
        
        score += value
        scoreBoard.text = "Score: \(score)"
        
        word = ""
        updateWordBoard()
    }
    
    func toggleBackground() {
        if (showBackground) {
            showBackground = false
            backGround.removeFromParent()
        }
        else {
            showBackground = true
            addChild(backGround)
        }
    }
    
    func bigifyFadeAndVanish(thing: SKSpriteNode) {
        let bigify = SKAction.scaleTo(10,   duration: 0.5)
        let fade   = SKAction.fadeOutWithDuration(0.5)
        thing.runAction(bigify)
        thing.runAction(fade, completion: {thing.removeFromParent()})
    }
    
    
    // contacts and collisions
    func didBeginContact(contact: SKPhysicsContact) {
        if ((contact.bodyA.categoryBitMask == zombieCategory) && (contact.bodyB.categoryBitMask == zombieCategory)) {
            let zombie1 = contact.bodyA.node as Zombie
            zombie1.randomDirection()
            
            let zombie2 = contact.bodyB.node as Zombie
            zombie2.randomDirection()
        }
        
        let all = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch all {
            case librarianHitPlayfield:
                println("nope")
            
            case zombieHitPlayfield, zombieHitTitle:
                println("grrr Argh")
                let zombie : Zombie = contact.bodyA.categoryBitMask == zombieCategory ? contact.bodyA.node as Zombie : contact.bodyB.node as Zombie
                zombie.randomDirection()
            
            case zombieHitLibrarian:
                println("BRAINS!!@")
            
            case catHitPlayfield:
                println("SPLAT!!@")
                let cat = contact.bodyA.categoryBitMask == catCategory ? contact.bodyA : contact.bodyB
                cat.node?.removeFromParent()
            
            case catHitZombie:
                println("meow meow meow")
                var cat: Cat
                var zombie: Zombie
            
                if (contact.bodyA.categoryBitMask == catCategory) {
                    cat    = contact.bodyA.node as Cat
                    zombie = contact.bodyB.node as Zombie
                }
                else {
                    zombie = contact.bodyA.node as Zombie
                    cat    = contact.bodyB.node as Cat
                }
            
                let freeLetter = zombie.die()
                freeLetter.fontSize = 36
                freeLetter.physicsBody = SKPhysicsBody(rectangleOfSize: freeLetter.frame.size)
                freeLetter.physicsBody.categoryBitMask    = letterCategory
                freeLetter.physicsBody.contactTestBitMask = playfieldCategory
                addChild(freeLetter)
            
                cat.removeFromParent()
            
            case letterHitPlayfield:
                println("....................schlorP")
                let letter = contact.bodyA.categoryBitMask == letterCategory ? contact.bodyA.node as Letter : contact.bodyB.node as Letter
                addLetterToWord(letter)
            
            default:
                println("...ping...")
        }
    }
}

extension GameScene {
    func handleKeyEvent(event: NSEvent, keyDown down: Bool) {
        for character in event.characters.unicodeScalars {
            switch character {
                case "\\": // actually want this to be return but not sure how to specify that here
                    if (down && !gameOn) {
                        startGame()
                    }
                    else {
                        // pause feature goes here
                    }
                
                case "w":
                    down ? librarian.walk(Character.heading.up)    : librarian.stop()
                
                case "a":
                    down ? librarian.walk(Character.heading.left)  : librarian.stop()
                
                case "d":
                    down ? librarian.walk(Character.heading.right) : librarian.stop()
                
                case "s":
                    down ? librarian.walk(Character.heading.down)  : librarian.stop()
                
                case " ":
                    down ? releaseCat() : ()
                
                case "z":
                    down ? addZombie()  : ()
                
                case "2":
                    down ? shhh()  : ()
                
                case "n":
                    down ? dropLastLetter()  : ()
                
                case "b":
                    down ? toggleBackground() : ()
                
                case "m":
                    down ? scoreWord() : ()
                
                default: ()
            }
        }
    }
    
    override func keyDown(event: NSEvent) {
        handleKeyEvent(event, keyDown: true)
    }
    
    override func keyUp(event: NSEvent) {
        handleKeyEvent(event, keyDown: false)
    }
}

