//
//  FirstLevel.swift
//  
//
//  Created by Nicolas Nascimento on 23/06/15.
//
//

import UIKit
import SpriteKit

class EarthLevel: GameScene, GameSceneProtocol {
    
    let imageNameArray = ["grow", "shrink", "speedup", "speeddown"]
    
    override func gravityForLevel() -> CGVector {
        return CGVector(dx: 0, dy: -9.8)
    }
    override func maximumAmountOfObjectsForLevel() -> Int {
        return 20
    }
    override func groundImageName() -> String {
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
    }
    override func allObjectsHaveBeenCreated() {
    }
}
