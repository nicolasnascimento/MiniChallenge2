//
//  MoonLevel.swift
//  
//
//  Created by Nicolas Nascimento on 24/06/15.
//
//

import UIKit
import SpriteKit

class MoonLevel: GameScene {
    
    let imageNameArray = ["grow", "shrink", "speedup", "speeddown"]
    
    override func gravityForLevel() -> CGVector {
        return CGVector(dx: 0, dy: -1.622)
    }
    override func maximumAmountOfObjectsForLevel() -> Int {
        return 20
    }
    override func groundImageName() -> String {
        return "four"
    }
    override func backgroundImageName() -> String {
        return "four"
    }
    override func objectsForRound() -> [SKSpriteNode] {
        var obstacle = SKSpriteNode(imageNamed: imageNameArray[ Int(arc4random_uniform(3)) ])
        obstacle.name = "obstacle"
        obstacle.createPhysicsBodyForSelfWithCategory(OBSTACLE_CATEGORY, contactCategory: HERO_CATEGORY , collisionCategory: 0)
        obstacle.physicsBody?.affectedByGravity = false
        return [obstacle];
        
    }
    override func heroDidTouchObject(hero: Hero, object: SKSpriteNode) {
        super.heroDidTouchObject(hero, object: object)
        println( object.name )
    }
    override func allObjectsHaveBeenCreated() {
        
        
        super.allObjectsHaveBeenCreated()
    }
}
