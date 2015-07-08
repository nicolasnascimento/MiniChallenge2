//
//  FirstLevel.swift
//  
//
//  Created by Nicolas Nascimento on 23/06/15.
//
//

import UIKit
import SpriteKit

class EarthLevel: GameScene {
    
    override var imageNameArray: [String] { return  ["obstacleIcon"] }
    
    override func gravityForLevel() -> CGVector {
        return CGVector(dx: 0, dy: -9.8)
    }
    override func maximumAmountOfObjectsForLevel() -> Int {
        return 50
    }
    override func groundImageName() -> String {
        return "four"
    }
    override func backgroundImageName() -> String {
        return "backgroundEarth"
    }
    override func planetName() -> String {
        return "Earth"
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
    override func messageForPopUp() -> String {
        return (self.facts[Int(arc4random_uniform(UInt32(self.facts.count)))] as TrueFalseQuestion).question
    }
    override func questionForPopUp() -> TrueFalseQuestion {
        return self.questions[Int(arc4random_uniform(UInt32(self.questions.count)))] as TrueFalseQuestion
    }
    override func transactionImageName() -> String {
        return "Transition Earth"
    }
    override func shouldPresentStartMenu() -> Bool {
        return true
    }
}
