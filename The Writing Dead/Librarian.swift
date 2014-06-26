//
//  Librarianswift
//  Puzzle librarians
//
//  Created by six on 6/23/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import SpriteKit

class Librarian: Character {
    let librarianTextures: Dictionary<heading, Array<SKTexture>> = [
        .up: [
            SKTexture(imageNamed: "Librarian.Up.1"),
            SKTexture(imageNamed: "Librarian.Up.2"),
            SKTexture(imageNamed: "Librarian.Up.3"),
        ],
        .down: [
            SKTexture(imageNamed: "Librarian.Down.1"),
            SKTexture(imageNamed: "Librarian.Down.2"),
            SKTexture(imageNamed: "Librarian.Down.3"),
        ],
        .left: [
            SKTexture(imageNamed: "Librarian.Left.1"),
            SKTexture(imageNamed: "Librarian.Left.2"),
            SKTexture(imageNamed: "Librarian.Left.3"),
        ],
        .right: [
            SKTexture(imageNamed: "Librarian.Right.1"),
            SKTexture(imageNamed: "Librarian.Right.2"),
            SKTexture(imageNamed: "Librarian.Right.3")
        ]
    ]

    init() {
        super.init(textures: librarianTextures)

        //setScale(0.85)
        position = CGPointMake(100, 100)
        zPosition = 3
        name  = "librarian"
        gait  = 100.0
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