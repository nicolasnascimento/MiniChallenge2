//
//  Util.swift
//  
//
//  Created by Nicolas Nascimento on 05/07/15.
//
//

import UIKit
import SpriteKit

class Util: NSObject {
    
    static func resizeSprite(sprite: SKSpriteNode, toFitHeight height: CGFloat){
        var aspectRatio = sprite.size.width/sprite.size.height
        sprite.size.height = height
        sprite.size.width = height * aspectRatio
    }
    static func resizeLabel(label: SKLabelNode, ToFitHeight height: CGFloat, andWidth width: CGFloat) -> SKLabelNode {
        while( label.frame.size.height > height || label.frame.size.width > width ) {
            label.fontSize *= 0.9
        }
        return label
    }
}
