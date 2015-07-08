//
//  BackgroundManager.swift
//  
//
//  Created by Nicolas Nascimento on 30/06/15.
//
//

import UIKit
import SpriteKit

class BackgroundManager: SKNode {
    
    
    let ANIMATION_TIME : Double = 20
    
    override var zPosition: CGFloat {
        didSet{
            self.firstLevel.zPosition = zPosition
            self.secondLevel.zPosition = zPosition + 1
            self.thirdLevel.zPosition = zPosition + 2
            self.fourthLevel.zPosition = zPosition + 3
        }
    }
    
    var firstLevel: SKSpriteNode
    var secondLevel: MovingBackground
    var thirdLevel: MovingBackground
    var fourthLevel: MovingBackground
    
    init(firstLevelImageName: String, secondLevelImageName: String, thirdLevelImageName: String, fourthLevelImageName: String, maxHeight: CGFloat, maxWidth: CGFloat) {
        self.firstLevel = SKSpriteNode(imageNamed: firstLevelImageName)
        
        
        self.secondLevel = MovingBackground(backgroundImageName: secondLevelImageName, maxHeight: maxHeight, maxWidth: maxWidth)
        
        self.thirdLevel = MovingBackground(backgroundImageName: thirdLevelImageName, maxHeight: maxHeight/2.8, maxWidth: maxWidth)
        self.fourthLevel = MovingBackground(backgroundImageName: fourthLevelImageName, maxHeight: maxHeight/8, maxWidth: maxWidth)
        
        super.init()
        
        Util.resizeSprite(self.firstLevel, toFitHeight: maxHeight)
        
        self.addChild(self.firstLevel)
        self.addChild(self.secondLevel)
        self.addChild(self.thirdLevel)
        self.addChild(self.fourthLevel)
        
        self.secondLevel.startAnimatingWithTimeInterval(ANIMATION_TIME)
        self.thirdLevel.startAnimatingWithTimeInterval(ANIMATION_TIME/2)
        self.fourthLevel.startAnimatingWithTimeInterval(ANIMATION_TIME/8)
        
        self.firstLevel.position.y = self.firstLevel.size.height/2
        self.secondLevel.position.y = self.secondLevel.front.size.height/2
        self.thirdLevel.position.y = self.thirdLevel.front.size.height/2
        self.fourthLevel.position.y = self.fourthLevel.front.size.height/2
        
        self.firstLevel.zPosition = 1
        self.secondLevel.zPosition = 2
        self.thirdLevel.zPosition = 3
        self.fourthLevel.zPosition = 4
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
