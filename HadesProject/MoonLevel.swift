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
        return 50
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
        if( arc4random_uniform(3) == 0 ) {
            return self.createCoinsFromSksFileNamed("CoinLine")
        }else{
            return super.objectsForRound()
        }
    }
    override func allObjectsHaveBeenCreated() {
        super.allObjectsHaveBeenCreated()
    }
    override func messageForPopUp() -> String {
        return (self.facts[Int(arc4random_uniform(UInt32(self.facts.count)))] as TrueFalseQuestion).question
    }
    override func transactionImageName() -> String {
        return "Transition Moon"
    }
    override func questionForPopUp() -> TrueFalseQuestion {
        return self.questions[Int(arc4random_uniform(UInt32(self.questions.count)))] as TrueFalseQuestion
    }
}
