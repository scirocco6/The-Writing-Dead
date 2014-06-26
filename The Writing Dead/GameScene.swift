//
//  GameScene.swift
//  Puzzle Zombies
//
//  Created by six on 6/23/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let words       = Words()
    
    let librarian   = Librarian()
    var zombieArray = Array<Zombie>()
    var catArray    = Array<Cat>()
    
    var level       = 1
    var score       = 0
    var zombieDelay = 5.0
    
    let playfieldCategory = UInt32(0x01 << 0)
    let librarianCategory = UInt32(0x01 << 1)
    let zombieCategory    = UInt32(0x01 << 2)
    let catCategory       = UInt32(0x01 << 3)
    let letterCategory    = UInt32(0x01 << 4)
    let platformCategory  = UInt32(0x01 << 5)
    
    @lazy var librarianHitPlayfield : UInt32 = self.librarianCategory | self.playfieldCategory
    @lazy var zombieHitPlayfield    : UInt32 = self.zombieCategory    | self.playfieldCategory
    @lazy var zombieHitLibrarian    : UInt32 = self.zombieCategory    | self.librarianCategory
    @lazy var catHitPlayfield       : UInt32 = self.catCategory       | self.playfieldCategory
    @lazy var catHitZombie          : UInt32 = self.catCategory       | self.zombieCategory
    @lazy var letterHitPlatform     : UInt32 = self.letterCategory    | self.platformCategory
    
    override func didMoveToView(view: SKView) {
        // world setup
        physicsWorld.contactDelegate = self
        
        physicsBody                 = SKPhysicsBody(edgeLoopFromRect: frame)
        //let newRect = CGRect(x: 0, y: 50, width: 1024, height: 768 - 50)
        //physicsBody                 = SKPhysicsBody(edgeLoopFromRect: newRect)
        physicsBody.friction        = 0
        physicsBody.categoryBitMask = playfieldCategory
        
        // player setup
        librarian.physicsBody.categoryBitMask = librarianCategory
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
        //
        // wait a while then add another zombie
        //
        runAction(SKAction.waitForDuration(zombieDelay), completion: {self.addZombie()})
        
        if (zombieDelay > 1) {
            zombieDelay -= 0.1
        }
    }
    
    func releaseCat() {
        println("meow!!@");
        let newCat = Cat(from: librarian.position, direction: librarian.direction)
        newCat.physicsBody.categoryBitMask    = catCategory
        newCat.physicsBody.contactTestBitMask = playfieldCategory | zombieCategory       // touching causes event
        
        catArray += newCat
        
        addChild(newCat)
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
            
        case zombieHitPlayfield:
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
            freeLetter.physicsBody = SKPhysicsBody(rectangleOfSize: freeLetter.frame.size)
            
            
            addChild(freeLetter)
            
            
            cat.removeFromParent()
            
        default:
            println("...ayup")
        }
    }
}

extension GameScene {
    func handleKeyEvent(event: NSEvent, keyDown down: Bool) {
        /*
        if event.modifierFlags & .NumericPadKeyMask {
        for keyChar in event.charactersIgnoringModifiers.unicodeScalars {
        switch UInt32(keyChar) {
        /*
        case 0xF700:
        defaultPlayer.moveForward = downOrUp
        
        case 0xF702:
        defaultPlayer.moveLeft = downOrUp
        
        case 0xF703:
        defaultPlayer.moveRight = downOrUp
        */
        case 0xF701:
        librarian.librarianDownWalkForever
        
        default: ()
        }
        }
        }
        */
        
        let characters = event.characters
        for character in characters.unicodeScalars {
            switch character {
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

