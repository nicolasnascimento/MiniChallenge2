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
    
    override var imageNameArray: [String] { return  ["obstacleIcon"] }
    
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
        return "ola2"
    }
    override func planetName() -> String {
        return "Moon"
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
    override func transactionImageName() -> String {
        return "Transition Moon"
    }
}
