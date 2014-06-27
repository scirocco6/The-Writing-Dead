//
//  Character.swift
//  Puzzle Zombies
//
//  Created by six on 6/24/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import SpriteKit

class Character: SKSpriteNode {
    enum heading : Int {
        case up = 0
        case down
        case left
        case right
    }
    
    let textures: Dictionary<heading, Array<SKTexture>> = [
        .up:    [SKTexture()],
        .down:  [SKTexture()],
        .left:  [SKTexture()],
        .right: [SKTexture()]
    ]
    var stoppedTexture = SKTexture()
    
    let walks: Dictionary<heading, SKAction> = [
        .up:    SKAction(),
        .down:  SKAction(),
        .left:  SKAction(),
        .right: SKAction()
    ]
    
    var upWalkForever: SKAction = SKAction()
    
    var walking   = false
    var direction = heading.down
    var gait      = 0.0
    
    func stop() {
        removeActionForKey("walk")
        walking = false
        physicsBody.velocity = CGVectorMake(0, 0)
    }
    
    func walk(dir : heading) {
        if (direction == dir && walking == true) { // if already walking that direction just keep walking
            return
        }
        
        removeActionForKey("walk")
        direction = dir
        walking = true
        
        var speed = physicsBody.velocity.dx > physicsBody.velocity.dy ? physicsBody.velocity.dx : physicsBody.velocity.dy
        speed = gait > speed ? gait : speed
        
        runAction(walks[dir], withKey:"walk")

        switch(dir) {
            case .up:
                physicsBody.velocity = CGVectorMake(0, speed)
            case .down:
                physicsBody.velocity = CGVectorMake(0, speed * -1)
            case .left:
                physicsBody.velocity = CGVectorMake(speed * -1, 0)
            case .right:
                physicsBody.velocity = CGVectorMake(speed, 0)
        }
    }
    
    init(textures: Dictionary<heading, Array<SKTexture>>) {
        let downTextures = textures[.down] as Array
        stoppedTexture   = downTextures[downTextures.count - 1]
        
        super.init(texture: stoppedTexture)

        physicsBody = SKPhysicsBody(rectangleOfSize: frame.size)
        physicsBody.friction = 0
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.linearDamping = 0
        
        let upWalk    = SKAction.animateWithTextures(textures[.up],    timePerFrame:0.3)
        let downWalk  = SKAction.animateWithTextures(textures[.down],  timePerFrame:0.3)
        let leftWalk  = SKAction.animateWithTextures(textures[.left],  timePerFrame:0.3)
        let rightWalk = SKAction.animateWithTextures(textures[.right], timePerFrame:0.3)
        
        walks[.up]    = SKAction.repeatActionForever(upWalk)
        walks[.down]  = SKAction.repeatActionForever(downWalk)
        walks[.left]  = SKAction.repeatActionForever(leftWalk)
        walks[.right] = SKAction.repeatActionForever(rightWalk)
    }
//
// junk needed just to make shiny happy
//
    init() {
        super.init()
    }
    
    init(texture: SKTexture!) {
        super.init(texture: texture)
    }
    
    init(texture: SKTexture!, color: NSColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
}
