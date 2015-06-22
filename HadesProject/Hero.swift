//
//  Hero.swift
//  HadesProject
//
//  Created by Nicolas Nascimento on 03/06/15.
//  Copyright (c) 2015 OurCompany. All rights reserved.
//

import UIKit
import SpriteKit

class Hero: SKSpriteNode {
    
    
    func createPhysicsBodyForSelfWithCategory(category: UInt32, contactCategory: UInt32, collisionCategory: UInt32) {
        if let body = self.physicsBody {
            body.categoryBitMask = category
            body.contactTestBitMask = contactCategory
            body.collisionBitMask = collisionCategory
        } else {
            let body = SKPhysicsBody(texture: self.texture!, size: self.size)
            body.categoryBitMask = category
            body.contactTestBitMask = contactCategory
            body.collisionBitMask = collisionCategory
            body.dynamic = true
            self.physicsBody = body
        }
    }
}
