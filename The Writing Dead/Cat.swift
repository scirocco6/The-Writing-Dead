//
//  Cat.swift
//  Puzzle Zombies
//
//  Created by six on 6/25/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import SpriteKit

class Cat: Character {
    let catTextures: Dictionary<heading, Array<SKTexture>> = [
        .up: [
            SKTexture(imageNamed: "Cat.Up.1"),
            SKTexture(imageNamed: "Cat.Up.2"),
            SKTexture(imageNamed: "Cat.Up.3"),
        ],
        .down: [
            SKTexture(imageNamed: "Cat.Down.1"),
            SKTexture(imageNamed: "Cat.Down.2"),
            SKTexture(imageNamed: "Cat.Down.3"),
        ],
        .left: [
            SKTexture(imageNamed: "Cat.Left.1"),
            SKTexture(imageNamed: "Cat.Left.2"),
            SKTexture(imageNamed: "Cat.Left.3"),
        ],
        .right: [
            SKTexture(imageNamed: "Cat.Right.1"),
            SKTexture(imageNamed: "Cat.Right.2"),
            SKTexture(imageNamed: "Cat.Right.3")
        ]
    ]
    
    init(from: CGPoint, direction: heading) {
        super.init(textures: catTextures)
        
        physicsBody!.linearDamping = -0.7

        position = from
        zPosition = 2
        name  = "cat"
        gait  = 200.0
        walk(direction)
    }
    
    
    // more shiny boilerplate
    required init(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
}