//
//  Zombie.swift
//  Puzzle Zombies
//x
//  Created by six on 6/24/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import SpriteKit

class Zombie: Character {
    let zombieTextures: Dictionary<heading, Array<SKTexture>> = [
        .up: [
            SKTexture(imageNamed: "Zombie.Up.1"),
            SKTexture(imageNamed: "Zombie.Up.2"),
            SKTexture(imageNamed: "Zombie.Up.3"),
            SKTexture(imageNamed: "Zombie.Up.4")
        ],
        .down: [
            SKTexture(imageNamed: "Zombie.Down.1"),
            SKTexture(imageNamed: "Zombie.Down.2"),
            SKTexture(imageNamed: "Zombie.Down.3"),
            SKTexture(imageNamed: "Zombie.Down.4")
        ],
        .left: [
            SKTexture(imageNamed: "Zombie.Left.1"),
            SKTexture(imageNamed: "Zombie.Left.2"),
            SKTexture(imageNamed: "Zombie.Left.3"),
            SKTexture(imageNamed: "Zombie.Left.4")
        ],
        .right: [
            SKTexture(imageNamed: "Zombie.Right.1"),
            SKTexture(imageNamed: "Zombie.Right.2"),
            SKTexture(imageNamed: "Zombie.Right.3"),
            SKTexture(imageNamed: "Zombie.Right.4")
        ]
    ]
    
    let letterNode = SKLabelNode(fontNamed:"Chalkduster") // this will be the letter the zombie is carrying

    init(letter: String) {
        println("The Writing Dead   \(letter) is for BRAINS!!!!@") // the literate dead? The reading dead?
        
        super.init(textures: zombieTextures)
        
        physicsBody.linearDamping = -0.2
        
        position = CGPointMake(CGFloat(arc4random_uniform(850)) + 100.0, CGFloat(arc4random_uniform(600)) + 100.0)
        name     = "zombie"
        gait     = 30.0
        randomDirection()
        
        letterNode.text      = letter
        letterNode.fontSize  = 25
        letterNode.zPosition = zPosition + 1
        addChild(letterNode)
    }
    
    func randomDirection() {
        walk(heading.fromRaw(Int(arc4random_uniform(4)))!)
    }
    
    func die() -> SKLabelNode {
        stop()
        letterNode.position = position
        letterNode.removeFromParent()
        removeFromParent()
        
        return letterNode
    }
//
// junk needed just to make shiny happy
//
    init(texture: SKTexture!) {
        super.init(texture: texture)
    }
    
    init(texture: SKTexture!, color: NSColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
}