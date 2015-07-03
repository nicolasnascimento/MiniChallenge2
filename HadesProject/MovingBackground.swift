//
//  MovingBackground.swift
//  
//
//  Created by Nicolas Nascimento on 01/07/15.
//
//

import UIKit
import SpriteKit

class MovingBackground: SKNode {
    
    var front: SKSpriteNode
    var rear: SKSpriteNode
    var maxWidth: CGFloat
    var maxHeight: CGFloat
    var textureName: String
    var ANIMATION_DURATION: Double = 0.0
    var INITIAL_REAR_POSITION: CGFloat = 0.0
    
    var moveLeft: SKAction! = nil
    var nextImage: SKSpriteNode! = nil
    
    init( backgroundImageName: String, maxHeight: CGFloat, maxWidth: CGFloat) {
        self.textureName = backgroundImageName
        
        self.front = SKSpriteNode(imageNamed: backgroundImageName)
        self.rear = SKSpriteNode(imageNamed: backgroundImageName)
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func startAnimatingWithTimeInterval(intervalTime: Double) {
        self.ANIMATION_DURATION = intervalTime
        self.front = SKSpriteNode(imageNamed: self.textureName)
        self.rear = SKSpriteNode(imageNamed: self.textureName)
        self.nextImage = SKSpriteNode(imageNamed: self.textureName)
        self.adaptBackground(self.nextImage)
        self.adaptBackground(self.front)
        self.adaptBackground(self.rear)
        self.rear.position.x += (self.rear.size.width)
        self.INITIAL_REAR_POSITION = self.rear.position.x
        self.nextImage.position.x = self.INITIAL_REAR_POSITION
        
        self.moveLeft = SKAction.moveByX(-self.front.size.width, y: 0, duration: ANIMATION_DURATION)
        
        self.front.runAction(self.moveLeft, completion: onMovementFinish)
        self.rear.runAction(self.moveLeft)
        
        self.addChild(self.front)
        self.addChild(self.rear)
        
    }
    private func adaptBackground( background: SKSpriteNode ) {
        if( background.size.width > background.size.height ) {
            let aspectRatio = background.size.width / background.size.height
            background.size.height = maxHeight
            background.size.width = background.size.height * aspectRatio
        } else {
            let aspectRatio = background.size.height / background.size.width
            background.size.width = maxWidth
            background.size.height = background.size.width * aspectRatio
        }
        //background.position.y = background.size.height/2
        background.position.x = background.size.width/2
        background.zPosition = 1
    }
    
    private func onMovementFinish() {
        
            //self.front.removeAllActions()
            //self.front.removeFromParent()
        self.front = self.rear
        self.rear = self.nextImage
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            self.nextImage = SKSpriteNode(imageNamed: self.textureName)
            self.adaptBackground(self.nextImage)
            self.nextImage.position.x = self.INITIAL_REAR_POSITION
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            self.addChild(self.rear)
            self.front.runAction(self.moveLeft, completion: self.onMovementFinish)
            self.rear.runAction(self.moveLeft)
        }
        
            //self.adaptBackground(self.rear)
            //self.rear.position.x = self.INITIAL_REAR_POSITION
            
        
    }
}
