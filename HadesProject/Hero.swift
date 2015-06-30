//
//  Hero.swift
//  HadesProject
//
//  Created by Nicolas Nascimento on 03/06/15.
//  Copyright (c) 2015 OurCompany. All rights reserved.
//

import UIKit
import SpriteKit

enum Side {
    case Right, Left
}


// Useful Constants
let RESIZING_FACTOR: CGFloat = 1.5
let INVISIBILTY_FACTOR: CGFloat = 0.5
let POWER_UP_DURATION: Double = 1.0


// Actions
let resizeUpAction = SKAction.scaleTo(RESIZING_FACTOR, duration: 0.0)
let resizeDownAction = SKAction.scaleTo(1.0/RESIZING_FACTOR, duration: 0.0)
let restoreSizeAction = SKAction.scaleTo(1.0, duration: 0.0)
let waitAction = SKAction.waitForDuration(POWER_UP_DURATION)

class Hero: SKSpriteNode {
    
    var respositivitySide: Side
    var shouldHitObjects: Bool
    var isHittingTheGround: Bool = true
    var coinsCaptured: Int = 0
    var coinMultiplier: Int = 1
    var coinMagnet: SKFieldNode = SKFieldNode()
    
    init(imageNamed imageName: String = "", respositivitySide: Side = .Right) {
        self.respositivitySide = respositivitySide
        self.shouldHitObjects = true
        let textureForImage = SKTexture(imageNamed: imageName)
        super.init(texture: textureForImage, color: UIColor.clearColor(), size: textureForImage.size())
    }
    
    init(texture: SKTexture, respositivitySide: Side = .Right) {
        self.respositivitySide = respositivitySide
        self.shouldHitObjects = true
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func invertResposivitySide() {
        self.respositivitySide = self.respositivitySide == .Right ? .Left : .Right
    }
    func resizeUp() {
        println("resizing up")
        var grow = SKAction.scaleTo(RESIZING_FACTOR, duration: 0.0)
        var recreatePhysicsBody = SKAction.customActionWithDuration(0.0, actionBlock: { (node, period) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.recreatePhysicsBody()
            }
        })
        var wait = SKAction.waitForDuration(POWER_UP_DURATION)
        var restoreSize = SKAction.scaleTo(1, duration: 0.0)
        
        self.runAction(SKAction.sequence([grow, recreatePhysicsBody, wait, restoreSize, recreatePhysicsBody]))
    }
    func resizeDown() {
        println("resizing down")
        
        var shrink = SKAction.scaleTo(1.0/RESIZING_FACTOR, duration: 0.0)
        var recreatePhysicsBody = SKAction.customActionWithDuration(0.0, actionBlock: { (node, period) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.recreatePhysicsBody()
            }
        })
        var wait = SKAction.waitForDuration(POWER_UP_DURATION)
        var restoreSize = SKAction.scaleTo(1, duration: 0.0)
        
        self.runAction(SKAction.sequence([shrink, recreatePhysicsBody, wait, restoreSize, recreatePhysicsBody]))
    }
    
    func turnToInvisible() {
        
        self.alpha = INVISIBILTY_FACTOR
        self.shouldHitObjects = false
        self.runAction(SKAction.waitForDuration(POWER_UP_DURATION), completion: { () -> Void in
            self.alpha = CGFloat(1.0)
            self.shouldHitObjects = true
        })
    }
    
    func doubleCoinMultiplier() {
        self.coinMultiplier *= 2
        self.runAction(waitAction, completion: { () -> Void in
            self.coinMultiplier /= 2
        })
    }
    
    func activateCoinMagnet() {
        println("activateCoinMagnet")
        self.coinMagnet = SKFieldNode.electricField()
        self.coinMagnet.strength = 10000
        self.parent!.addChild(coinMagnet)
    }
    
    private func recreatePhysicsBody() {
        if self.physicsBody == nil {
            return
        }
        var velocity = self.physicsBody!.velocity
        var mass = self.physicsBody!.mass
        var category = self.physicsBody!.categoryBitMask
        var contact = self.physicsBody!.contactTestBitMask
        var collision = self.physicsBody!.collisionBitMask
        self.physicsBody = nil
        self.createPhysicsBodyForSelfWithCategory(category, contactCategory: contact, collisionCategory: collision, squaredBody: true)
        self.physicsBody?.velocity = velocity
        self.physicsBody?.mass = mass
    }
}
