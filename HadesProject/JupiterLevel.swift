//
//  JupiterLevel.swift
//  
//
//  Created by Nicolas Nascimento on 24/06/15.
//
//

import UIKit
import SpriteKit

class JupiterLevel: GameScene {
 
    override var imageNameArray: [String] { return  ["grow", "shrink", "speedup", "speeddown"] }
    
    override func gravityForLevel() -> CGVector {
        return CGVector(dx: 0, dy: -24.79)
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
        return "Jupiter"
    }
    override func objectsForRound() -> [SKSpriteNode] {
        return super.objectsForRound()
    }
    override func heroDidTouchObject(hero: Hero, object: SKSpriteNode) {
        super.heroDidTouchObject(hero, object: object)
    }
    override func allObjectsHaveBeenCreated() {
        
        
        super.allObjectsHaveBeenCreated()
    }

}
