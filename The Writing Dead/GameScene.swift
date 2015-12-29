//
//  GameScene.swift
//  Puzzle Zombies
//
//  Created by six on 6/23/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate, controlDelegate {
    let words       = Words()
    var word        = String()
    
    let librarian   = Librarian()
    var zombieArray = Array<Zombie>()
    var catArray    = Array<Cat>()
    var shelfArray  = Array<SKSpriteNode>()

    var level       = 1
    var score       = 0
    let maxShh      = 0
    var shh         = 3
    let maxDelay    = 15.0
    var zombieDelay = 15.0
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
    
    lazy var librarianHitPlayfield : UInt32 = self.librarianCategory | self.playfieldCategory
    lazy var zombieHitPlayfield    : UInt32 = self.zombieCategory    | self.playfieldCategory
    lazy var zombieHitLibrarian    : UInt32 = self.zombieCategory    | self.librarianCategory
    lazy var catHitPlayfield       : UInt32 = self.catCategory       | self.playfieldCategory
    lazy var catHitZombie          : UInt32 = self.catCategory       | self.zombieCategory
    lazy var letterHitPlayfield    : UInt32 = self.letterCategory    | self.playfieldCategory
    lazy var zombieHitTitle        : UInt32 = self.zombieCategory    | self.titleCategory

//#MARK: - controller setup
    var controller = Controller()

    override func didMoveToView(view: SKView) {
        controller.delegate = self
        
//#MARK: - playfield setup
        backGround           = SKSpriteNode(texture: backgroundTexture, size: size)
        backGround.position  = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        backGround.zPosition = -1
        addChild(backGround)
        
        titleSplash.position    = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) + 100)
        titleSplash.physicsBody = SKPhysicsBody(rectangleOfSize: titleSplash.frame.size)
        titleSplash.physicsBody!.affectedByGravity = false
        titleSplash.physicsBody!.usesPreciseCollisionDetection = true
        addChild(titleSplash)
        //titleSplash.runAction(SKAction.playSoundFileNamed("words.mp3", waitForCompletion: false))
        
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
        physicsBody!.friction        = 0
        physicsBody!.categoryBitMask = playfieldCategory

//#MARK: - player setup
        librarian.physicsBody!.categoryBitMask  = librarianCategory
        librarian.physicsBody!.collisionBitMask = playfieldCategory | zombieCategory       // touching causes event

        addZombie()
    }

//#MARK: - game logic
    func startGame() {
        while let zombie = zombieArray.popLast() { // remove all of the attract mode zombies
            zombie.removeFromParent()
        }
        
        zombieDelay = maxDelay
        shh         = maxShh
        score       = 0
        
        titleSplash.removeFromParent()
        addChild(librarian)
        addZombie()
    }
    
    func addZombie() {
        let newZombie = Zombie(letter: words.nextLetter())
        newZombie.physicsBody!.categoryBitMask    = zombieCategory
        newZombie.physicsBody!.contactTestBitMask = playfieldCategory | librarianCategory | zombieCategory   // touching causes event
        
        addChild(newZombie)
        
        zombieArray.append(newZombie)
        
        if (zombieDelay > 1) {
            zombieDelay -= 0.001 // reduce the delay between new zombies.  This needs play testing badly level/bonus etc should have an effect
        }
        // wait a while then add another zombie
        runAction(SKAction.waitForDuration(zombieDelay), completion: {self.addZombie()})
    }
    
    func releaseCat() {
        print("meow!!@");
        let newCat = Cat(from: librarian.position, direction: librarian.direction)
        newCat.physicsBody!.categoryBitMask    = catCategory
        newCat.physicsBody!.contactTestBitMask = playfieldCategory | zombieCategory       // touching causes event
        newCat.physicsBody!.collisionBitMask   = playfieldCategory | zombieCategory       // touching causes event
        
        catArray.append(newCat)
        
        addChild(newCat)
    }
    
    func shhh() {
        if(shh == 0) {
            print("No shh for you!!@")
            return()
        }
        shh--
        shhhBoard.text = "\(shh) :shhH"
        print("shh happens")
        
        let shhSprite = SKSpriteNode(imageNamed: "Shh")

        shhSprite.setScale(0.1)
        shhSprite.position = backGround.position
        addChild(shhSprite)
        shhSprite.runAction(SKAction.playSoundFileNamed("shh.mp3", waitForCompletion: false))
        bigifyFadeAndVanish(shhSprite)
        
        zombieDelay = maxDelay
        
        while let zombie = zombieArray.popLast() { // remove all of the attract mode zombies
            zombie.letterNode.keep = false
            killZombie(zombie)
        }
        
        // originally shh just slowed all of the zombies down
        //        for zombie in zombieArray {
        //    zombie.shhh()
        //}
    }
    
    func addLetterToWord(letter: Letter) {
        letter.removeFromParent()
        
        word += letter.text!
        updateWordBoard()
    }
    
    func dropLastLetter() {
        // TODO: need to make sure word is present before decrementing
        word = word[word.startIndex...word.endIndex.predecessor()]
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
            print("No \(word) for you!!@")
            return()
        }
        
        print("\(word) is a yummy \(word)")
        
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
    
    func killZombie(zombie: Zombie) {
        let freeLetter = zombie.die()
        freeLetter.fontSize = 36
        freeLetter.physicsBody = SKPhysicsBody(rectangleOfSize: freeLetter.frame.size)
        freeLetter.physicsBody!.categoryBitMask    = letterCategory
        freeLetter.physicsBody!.contactTestBitMask = playfieldCategory
        addChild(freeLetter)
    }

//# MARK: - contacts and collisions
    func didBeginContact(contact: SKPhysicsContact) {
        if ((contact.bodyA.categoryBitMask == zombieCategory) && (contact.bodyB.categoryBitMask == zombieCategory)) {
            let zombie1 = contact.bodyA.node as! Zombie
            zombie1.randomDirection()
            
            let zombie2 = contact.bodyB.node as! Zombie
            zombie2.randomDirection()
        }
        
        let all = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch all {
            case librarianHitPlayfield:
                print("nope")
            
            case zombieHitPlayfield, zombieHitTitle:
                print("grrr Argh")
                let zombie : Zombie = contact.bodyA.categoryBitMask == zombieCategory ? contact.bodyA.node as! Zombie : contact.bodyB.node as! Zombie
                zombie.randomDirection()
            
            case zombieHitLibrarian:
                print("BRAINS!!@")
            
            case catHitPlayfield:
                print("SPLAT!!@")
                let cat = contact.bodyA.categoryBitMask == catCategory ? contact.bodyA : contact.bodyB
                cat.node?.removeFromParent()
            
            case catHitZombie:
                print("meow meow meow")
                var cat: Cat
                var zombie: Zombie
            
                if (contact.bodyA.categoryBitMask == catCategory) {
                    cat    = contact.bodyA.node as! Cat
                    zombie = contact.bodyB.node as! Zombie
                }
                else {
                    zombie = contact.bodyA.node as! Zombie
                    cat    = contact.bodyB.node as! Cat
                }
                
                killZombie(zombie)
                cat.removeFromParent()
            
            case letterHitPlayfield:
                print("....................schlorP")
                let letter = contact.bodyA.categoryBitMask == letterCategory ? contact.bodyA.node as! Letter : contact.bodyB.node as! Letter
                letter.keep ? addLetterToWord(letter) : letter.removeFromParent()
            
            default:
                print("...ping...")
        }
    }
    
//# MARK: - controlDelegate
    func pause() {
        self.paused = self.paused ? false : true
        self.paused ? print("*PAUSE*") : print("*resumed*")
    }

//# MARK: - input handling
    func handleKeyEvent(event: NSEvent, keyDown down: Bool) {
        for character in event.charactersIgnoringModifiers!.unicodeScalars {
            switch character {
                case "\\": // actually want this to be return but not sure how to specify that here
                    if down {
                        if !gameOn {
                            startGame()
                        }
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
                
                case "m":
                    down ? scoreWord() : ()
                
                case "p":
                    down ? pause() : ()
                
                case "b":
                    down ? toggleBackground() : ()
                
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

