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
    
    var walks: Dictionary<heading, SKAction> = [
        .up:    SKAction(),
        .down:  SKAction(),
        .left:  SKAction(),
        .right: SKAction()
    ]
    
    var upWalkForever: SKAction = SKAction()
    
    var walking       = false
    var direction     = heading.down
    var gait: CGFloat = 0.0
    
    func stop() {
        removeAction(forKey: "walk")
        walking = false
        physicsBody!.velocity = CGVector(dx: 0, dy: 0)
    }
    
    func walk(_ dir : heading) {
        if (direction == dir && walking == true) { // if already walking that direction just keep walking
            return
        }
        
        removeAction(forKey: "walk")
        direction = dir
        walking = true
        
        var speed = physicsBody!.velocity.dx > physicsBody!.velocity.dy ? physicsBody!.velocity.dx : physicsBody!.velocity.dy
        speed = gait > speed ? gait : speed
        
        run(walks[dir]!, withKey:"walk")

        switch(dir) {
            case .up:
                physicsBody!.velocity = CGVector(dx: 0, dy: speed)
            case .down:
                physicsBody!.velocity = CGVector(dx: 0, dy: speed * -1)
            case .left:
                physicsBody!.velocity = CGVector(dx: speed * -1, dy: 0)
            case .right:
                physicsBody!.velocity = CGVector(dx: speed, dy: 0)
        }
    }
    
    init(textures: Dictionary<heading, Array<SKTexture>>) {
        let downTextures = textures[.down]! as Array
        stoppedTexture   = downTextures[downTextures.count - 1]
        
        super.init(texture: stoppedTexture, color: NSColor.clear, size: stoppedTexture.size())

        physicsBody = SKPhysicsBody(rectangleOf: frame.size)
        physicsBody!.friction = 0
        physicsBody!.usesPreciseCollisionDetection = true
        physicsBody!.affectedByGravity = false
        physicsBody!.allowsRotation = false
        physicsBody!.linearDamping = 0
        
        let upWalk    = SKAction.animate(with: textures[.up]!,    timePerFrame:0.3)
        let downWalk  = SKAction.animate(with: textures[.down]!,  timePerFrame:0.3)
        let leftWalk  = SKAction.animate(with: textures[.left]!,  timePerFrame:0.3)
        let rightWalk = SKAction.animate(with: textures[.right]!, timePerFrame:0.3)
        
        walks[.up]    = SKAction.repeatForever(upWalk)
        walks[.down]  = SKAction.repeatForever(downWalk)
        walks[.left]  = SKAction.repeatForever(leftWalk)
        walks[.right] = SKAction.repeatForever(rightWalk)
    }

    // more shiny boilerplate
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
