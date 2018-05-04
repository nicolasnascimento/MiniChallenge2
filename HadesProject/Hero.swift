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
let POWER_UP_DURATION: Double = 5.0


// Actions
let resizeUpAction = SKAction.scale(to: RESIZING_FACTOR, duration: 0.0)
let resizeDownAction = SKAction.scale(to: 1.0/RESIZING_FACTOR, duration: 0.0)
let restoreSizeAction = SKAction.scale(to: 1.0, duration: 0.0)
let waitAction = SKAction.wait(forDuration: POWER_UP_DURATION)

class Hero: SKSpriteNode {
    
    var respositivitySide: Side
    var shouldHitObjects: Bool
    var isHittingTheGround: Bool = true
    var coinsCaptured: Int = 0
    var coinMultiplier: Int = 1
    var coinMagnet: SKFieldNode = SKFieldNode()
    var isSpaceKing: Bool = false
    var isFused: Bool = false
    
    init(imageNamed imageName: String = "", respositivitySide: Side = .Right) {
        self.respositivitySide = respositivitySide
        self.shouldHitObjects = true
        let textureForImage = SKTexture(imageNamed: imageName)
        super.init(texture: textureForImage, color: UIColor.clear, size: textureForImage.size())
    }
    
    init(texture: SKTexture, respositivitySide: Side = .Right) {
        self.respositivitySide = respositivitySide
        self.shouldHitObjects = true
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func restoreOriginalPhysicsProperties() {
        if let body = self.physicsBody {
            body.affectedByGravity = true
            body.restitution = 0.0
        }
    }
    func invertResposivitySide() {
        self.respositivitySide = self.respositivitySide == .Right ? .Left : .Right
    }
    func resizeUp() {
      //  println("resizing up")
        var grow = SKAction.scale(to:RESIZING_FACTOR, duration: 0.0)
        var recreatePhysicsBody = SKAction.customAction(withDuration: 0.0, actionBlock: { [unowned self] (node, period) -> Void in
            DispatchQueue.main.async {
                self.recreatePhysicsBody()
            }
        })
        var wait = SKAction.wait(forDuration: POWER_UP_DURATION)
        var restoreSize = SKAction.scale(to:1, duration: 0.0)
        
        self.run(SKAction.sequence([grow, recreatePhysicsBody, wait, restoreSize, recreatePhysicsBody]))
    }
    func resizeDown() {
      //  println("resizing down")
        
        var shrink = SKAction.scale(to:1.0/RESIZING_FACTOR, duration: 0.0)
        var recreatePhysicsBody = SKAction.customAction(withDuration: 0.0, actionBlock: { [unowned self]  (node, period) -> Void in
            DispatchQueue.main.async {
                self.recreatePhysicsBody()
            }
        })
        var wait = SKAction.wait(forDuration: POWER_UP_DURATION)
        var restoreSize = SKAction.scale(to:1, duration: 0.0)
        
        self.run(SKAction.sequence([shrink, recreatePhysicsBody, wait, restoreSize, recreatePhysicsBody]))
    }
    
    func turnToInvisible() {
        
        self.alpha = INVISIBILTY_FACTOR
        self.shouldHitObjects = false
        self.run(SKAction.wait(forDuration: POWER_UP_DURATION), completion: { [unowned self] () -> Void in
            self.alpha = CGFloat(1.0)
            self.shouldHitObjects = true
        })
    }
    
    func doubleCoinMultiplier() {
        self.coinMultiplier *= 2
        self.run(waitAction, completion: { () -> Void in
            self.coinMultiplier /= 2
        })
    }
    
    func activateCoinMagnet() {
      //  println("activateCoinMagnet")
        self.coinMagnet = SKFieldNode.electricField()
        self.coinMagnet.strength = 10000
        self.parent!.addChild(coinMagnet)
    }
    
    func fuseWithHero(_ hero: Hero ) {
        
        if( self.isFused || hero.isFused ) {
            return
        }
        
        var oldPosition = hero.position
        var shrink = SKAction.scale(to:0, duration: 0.2)
        var comeClose = SKAction.move(to: self.position, duration: 0.2)
        var goAway = SKAction.move(to: oldPosition, duration: 0.2)
        var scaleBack = SKAction.scale(to:1.0, duration: 0.2)
        var grow = SKAction.scale(to:RESIZING_FACTOR, duration: 0.0)
        var wait = SKAction.wait(forDuration: POWER_UP_DURATION)
        var recreatePhysicsBody = SKAction.customAction(withDuration: 0.0, actionBlock: { [unowned self] (node, period) -> Void in
            DispatchQueue.main.async {
                self.recreatePhysicsBody()
            }
        })
        self.isFused = true
        hero.isFused = true
        hero.run(SKAction.sequence([SKAction.group([shrink, comeClose]), recreatePhysicsBody]) )
        self.run(SKAction.group([shrink, comeClose]), completion: { () -> Void in
            DispatchQueue.main.async {
                self.run(SKAction.sequence([grow, recreatePhysicsBody, wait]), completion: { [unowned self] () -> Void in
                    DispatchQueue.main.async {
                        self.isFused = false
                        hero.isFused = false
                        self.run(SKAction.sequence([scaleBack, recreatePhysicsBody]))
                        hero.run(SKAction.sequence([SKAction.group([scaleBack, goAway]), recreatePhysicsBody]))
                    }
                })
            }
            
        })
        
    }
    
    func turnToSpaceKing() {
        self.isSpaceKing = true
        self.run(SKAction.wait(forDuration: POWER_UP_DURATION), completion: { [unowned self] () -> Void in
            self.isSpaceKing = false
        })
    }
    
    
    private func recreatePhysicsBody() {
        if self.physicsBody == nil {
            return
        }
        var velocity = self.physicsBody!.velocity
        var mass = (self.scene as! GameScene).HERO_MASS
        var category = self.physicsBody!.categoryBitMask
        var contact = self.physicsBody!.contactTestBitMask
        var collision = self.physicsBody!.collisionBitMask
        
        self.physicsBody = nil
        self.createPhysicsBodyForSelfWithCategory(category, contactCategory: contact, collisionCategory: collision, squaredBody: true)
        self.physicsBody?.velocity = velocity
        self.physicsBody?.mass = mass
    }
}
