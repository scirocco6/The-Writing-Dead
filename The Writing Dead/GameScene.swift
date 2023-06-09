//
//  GameScene.swift
//  Puzzle Zombies
//
//  Created by six on 6/23/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate, controlDelegate {

//#MARK: - variable setup
    let words       = Words()
    var word        = String()
    
    let librarian   = Librarian()
    var zombieArray = Array<Zombie>()
    var catArray    = Array<Cat>()
    var shelfArray  = Array<SKSpriteNode>()

    var level       = 1
    var score       = 0
    let maxShh      = 3
    var shh         = 0
    let maxDelay    = 10.0
    var zombieDelay = 10.0
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

    override func didMove(to view: SKView) {
        controller.delegate = self
        
//#MARK: - playfield setup
        backGround           = SKSpriteNode(texture: backgroundTexture, size: size)
        backGround.position  = CGPoint(x: frame.midX, y: frame.midY)
        backGround.zPosition = -1
        addChild(backGround)
        
        titleSplash.position    = CGPoint(x: frame.midX, y: frame.midY + 100)
        titleSplash.physicsBody = SKPhysicsBody(rectangleOf: titleSplash.frame.size)
        titleSplash.physicsBody!.affectedByGravity = false
        titleSplash.physicsBody!.usesPreciseCollisionDetection = true
        addChild(titleSplash)
        //titleSplash.runAction(SKAction.playSoundFileNamed("words.mp3", waitForCompletion: false))
        
        wordBoard.fontSize = 42
        wordBoard.position = CGPoint(x: frame.midX, y: 25)
        wordBoard.text     = word
        addChild(wordBoard)
        
        scoreBoard.position = CGPoint(x: 10, y: 5)
        scoreBoard.text     = "Score: \(score)"
        scoreBoard.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(scoreBoard)
        
        shhhBoard.position = CGPoint(x: 890, y: 5)
        shhhBoard.text     = "\(shh) :shhH"
        shhhBoard.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(shhhBoard)

        physicsWorld.contactDelegate = self
        
        let newRect                  = CGRect(x: 0, y: 75, width: frame.width, height: frame.height - 75)
        physicsBody                  = SKPhysicsBody(edgeLoopFrom: newRect)
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
        shhhBoard.text = "\(shh) :shhH"
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
        run(SKAction.wait(forDuration: zombieDelay), completion: {self.addZombie()})
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
        shh -= 1
        doShhh()
    }
    
    func doShhh() {
        shhhBoard.text = "\(shh) :shhH"
        print("shh happens")
        
        let shhSprite = SKSpriteNode(imageNamed: "Shh")

        shhSprite.setScale(0.1)
        shhSprite.position = backGround.position
        addChild(shhSprite)
        shhSprite.run(SKAction.playSoundFileNamed("shh.mp3", waitForCompletion: false))
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
    
    func addLetterToWord(_ letter: Letter) {
        letter.removeFromParent()
        
        word += letter.text!
        updateWordBoard()
    }

    func dropLastLetter() {
        if word.isEmpty { return }

        word.remove(at: word.index(before: word.endIndex))
        updateWordBoard()
    }
    
    func updateWordBoard() {
        wordBoard.text = word
        
        switch(words.wordValue(word)) {
        case 0:
            wordBoard.fontColor = SKColor.red
        case 1...9:
            wordBoard.fontColor = SKColor.green
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
        
        let bigWord = wordBoard.copy() as! SKNode
        addChild(bigWord)
        bigifyFadeAndVanish(bigWord)
        doShhh()
        
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
    
    func bigifyFadeAndVanish(_ thing: SKNode) {
        let bigify = SKAction.scale(to: 10,   duration: 0.5)
        let fade   = SKAction.fadeOut(withDuration: 0.5)
        thing.run(bigify)
        thing.run(fade, completion: {thing.removeFromParent()})
    }
    
    func killZombie(_ zombie: Zombie) {
        let freeLetter = zombie.die()
        freeLetter.fontSize = 36
        freeLetter.physicsBody = SKPhysicsBody(rectangleOf: freeLetter.frame.size)
        freeLetter.physicsBody!.categoryBitMask    = letterCategory
        freeLetter.physicsBody!.contactTestBitMask = playfieldCategory
        addChild(freeLetter)
    }

//# MARK: - contacts and collisions
    func didBegin(_ contact: SKPhysicsContact) {
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

//# MARK: - keyboard handling
    func handleKeyEvent(_ event: NSEvent, keyDown down: Bool) {
        for character in event.charactersIgnoringModifiers!.unicodeScalars {
            switch character {
                case "\\": // actually want this to be return but not sure how to specify that here
                    if down {
                        if !gameOn {
                            startGame()
                        }
                    }
                case "w":
                    down ? goUp()    : librarian.stop()
                
                case "a":
                    down ? goLeft()  : librarian.stop()
                
                case "d":
                    down ? goRight() : librarian.stop()
                
                case "s":
                    down ? goDown()  : librarian.stop()
                
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
    
//# MARK: - controlDelegate
    func pause() {
        self.isPaused = self.isPaused ? false : true
        self.isPaused ? print("*PAUSE*") : print("*resumed*")
    }
    
    override func keyDown(with event: NSEvent) {
        handleKeyEvent(event, keyDown: true)
    }
    
    override func keyUp(with event: NSEvent) {
        handleKeyEvent(event, keyDown: false)
    }
//# MARK: - librarian walk
    func goLeft() {
        librarian.walk(Character.heading.left)
    }
    func goRight() {
        librarian.walk(Character.heading.right)
    }
    func goUp() {
        librarian.walk(Character.heading.up)
    }
    func goDown() {
        librarian.walk(Character.heading.down)
    }
    func goStop() {
        librarian.stop()
    }
}

