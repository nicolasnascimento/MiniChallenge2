//
//  StartMenu.swift
//  
//
//  Created by Nicolas Nascimento on 01/07/15.
//
//

import UIKit
import SpriteKit

class StartMenu: SKNode {
    
    var DIVISIONS: CGFloat = 5.0
    
    var playButton: SKSpriteNode
    var tapToPlayButton: SKLabelNode
    var gameCenterButton: SKSpriteNode
    var storeButton: SKSpriteNode
    
    let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.5)
    let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.5)
    
    init(playButtonImageName: String, gameCenterButtonImageName: String, storeButtonImageName: String) {
        self.playButton = SKSpriteNode(imageNamed: playButtonImageName)
        self.gameCenterButton = SKSpriteNode(imageNamed: gameCenterButtonImageName)
        self.storeButton = SKSpriteNode(imageNamed: storeButtonImageName)
        self.tapToPlayButton = SKLabelNode(text: "Tap to Play")
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating( maxHeight: CGFloat, maxWidth: CGFloat ) {
        self.addChild(self.playButton)
        self.addChild(self.tapToPlayButton)
        self.addChild(self.gameCenterButton)
        self.addChild(self.storeButton)
        
        let divisionHeight = maxHeight/DIVISIONS
        
        self.resizeSprite(self.playButton, toFitHeight: 2.5*divisionHeight)
        self.resizeSprite(self.gameCenterButton, toFitHeight: divisionHeight)
        self.resizeSprite(self.storeButton, toFitHeight: divisionHeight)
        
        self.playButton.position.y += divisionHeight/2
        
        //self.playButton.position.y = self.playButton.frame.size.height/2
        self.tapToPlayButton.position.y = -self.playButton.frame.size.height/2
        self.tapToPlayButton.runAction(SKAction.repeatActionForever(SKAction.sequence([fadeOut, fadeIn])))
        
        self.gameCenterButton.position.y = self.playButton.position.y
        self.gameCenterButton.position.x = -(self.playButton.frame.size.width/1.5)
        
        self.storeButton.position.y = self.playButton.position.y
        self.storeButton.position.x = (self.playButton.frame.size.width/1.5)
    }
    
    private func resizeSprite( sprite: SKSpriteNode, toFitHeight height: CGFloat ) {
        var aspectRatio = sprite.frame.size.width/sprite.frame.size.height
        sprite.size.height = height
        sprite.size.width = sprite.size.height * aspectRatio
    }
}
