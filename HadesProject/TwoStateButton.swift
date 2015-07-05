//
//  TwoStateButton.swift
//  
//
//  Created by Nicolas Nascimento on 04/07/15.
//
//

import UIKit
import SpriteKit

class TwoStateButton: SKSpriteNode {
    
    var onTextureName: String
    var offTextureName: String
    var state: Bool
    
    
    init(onTextureName: String, offTextureName: String, initialState: Bool = true) {
        
        self.onTextureName = onTextureName
        self.offTextureName = offTextureName
        self.state = initialState
        
        var aTexture = SKTexture(imageNamed: ( initialState ? onTextureName : offTextureName ) )
        super.init(texture: aTexture, color: SKColor.clearColor(), size: aTexture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func changeState() {
        self.state = !self.state
        var aTexture = SKTexture(imageNamed: ( self.state ? onTextureName : offTextureName ))
        self.runAction(SKAction.setTexture(aTexture))
    }
    private func resizeSprite(sprite: SKSpriteNode, toFitHeight height: CGFloat) {
        var aspectRatio = sprite.size.width/sprite.size.height
        sprite.size.height = height
        sprite.size.width = height * aspectRatio
    }
}
