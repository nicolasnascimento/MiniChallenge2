//
//  NeptuneLevel.swift
//  
//
//  Created by Nicolas Nascimento on 24/06/15.
//
//

import UIKit
import SpriteKit

class NeptuneLevel: GameScene {
   
    override var imageNameArray: [String] { return  ["obstacleIcon"] }
    
    override func gravityForLevel() -> CGVector {
        return CGVector(dx: 0, dy: -11.15)
    }
    override func maximumAmountOfObjectsForLevel() -> Int {
        return 50
    }
    override func groundImageName() -> String {
        return "four"
    }
    override func backgroundImageName() -> String {
        return "ola"
    }
    override func planetName() -> String {
        return "Neptune"
    }
    override func objectsForRound() -> [SKSpriteNode] {
        return super.objectsForRound()
    }
    override func allObjectsHaveBeenCreated() {
        
        super.allObjectsHaveBeenCreated()
    }
    override func messageForPopUp() -> String {
        return (self.facts[Int(arc4random_uniform(UInt32(self.facts.count)))] as TrueFalseQuestion).question
    }
    override func transactionImageName() -> String {
        return "Transition Neptune"
    }
    override func questionForPopUp() -> TrueFalseQuestion {
        return self.questions[Int(arc4random_uniform(UInt32(self.questions.count)))] as TrueFalseQuestion
    }

}
