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
    override func backgroundImageName() -> String {
        return "ola"
    }
    override func planetName() -> String {
        return "Earth"
    }
    
//    let INVERT_PROBABILITY: Double = 10.0
//    let RESIZE_UP_PROBABILITY: Double = 7.5
//    let RESIZE_DOWN_PROBABILTY: Double = 7.5
//    let FUSION_PROBABILITY: Double = 10.0
//    let INVISIBILITY_PROBABILTY: Double = 15.0
//    let MULTIPLIER_PROBABILITY: Double = 25.0
//    let SPACE_KING_PROBABILITY: Double = 5.0
//    let COIN_MAGNET_PROBABILITY: Double = 20.0
    override func objectsForRound() -> [SKSpriteNode] {
        var obstacle = SKSpriteNode(imageNamed: imageNameArray[ Int(arc4random_uniform(3)) ])
        
        if( arc4random_uniform(100) < UInt32( self.POWER_UP_PROBABILITY ) ) {
            var probability = Double(arc4random_uniform(1000))/10.0
            
            if( probability < 100 && probability >= 75 ) {
                
            } else if( probability < 75 && probability >= 55 ) {
                
            } else if( probability < 55 && probability >= 40 ) {
                
            } else if( probability < 40 && probability >= 30 ) {
                
            } else if( probability < 30 && probability >= 20 ) {
                
            } else if( probability < 20 && probability >= 12.5 ) {
                
            } else if( probability < 12.5 && probability >= 5 ) {
                
            } else {
                
            }
            
        } else {
            
        }
        
        // Should be improved later
//        if( arc4random_uniform(3) == 0 ) {
//            obstacle.name = "PowerUp-Invert"
//        }else {
//            obstacle.name = "obstacle"
//        }
        obstacle.createPhysicsBodyForSelfWithCategory(OBSTACLE_CATEGORY, contactCategory: HERO_CATEGORY , collisionCategory: 0)
        obstacle.physicsBody?.affectedByGravity = false
        return [obstacle];
    }
    override func heroDidTouchObject(hero: Hero, object: SKSpriteNode) {
        super.heroDidTouchObject(hero, object: object)
        println("Earth")
    }
    override func allObjectsHaveBeenCreated() {
        super.allObjectsHaveBeenCreated()
    }
}
