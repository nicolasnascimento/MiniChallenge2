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
    var soundButton: SKSpriteNode
    var storeButton: SKSpriteNode
    
    let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.5)
    let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.5)
    
    init(playButtonImageName: String, gameCenterButtonImageName: String, soundButtonImageName: String, storeButtonImageName: String) {
        self.playButton = SKSpriteNode(imageNamed: playButtonImageName)
        self.gameCenterButton = SKSpriteNode(imageNamed: gameCenterButtonImageName)
        self.soundButton = SKSpriteNode(imageNamed: soundButtonImageName)
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
        self.addChild(self.soundButton)
        self.addChild(self.storeButton)
        
        let divisionHeight = maxHeight/DIVISIONS
        
        self.resizeSprite(self.playButton, toFitHeight: 2.5*divisionHeight)
        self.resizeSprite(self.gameCenterButton, toFitHeight: divisionHeight/2)
        self.resizeSprite(self.soundButton, toFitHeight: divisionHeight/2)
        self.resizeSprite(self.storeButton, toFitHeight: divisionHeight/2)
        
        self.playButton.position.y += divisionHeight/2
        
        //self.playButton.position.y = self.playButton.frame.size.height/2
        self.tapToPlayButton.position.y = -self.playButton.frame.size.height/2
        self.tapToPlayButton.runAction(SKAction.repeatActionForever(SKAction.sequence([fadeOut, fadeIn])))
        
        self.gameCenterButton.position.y = self.tapToPlayButton.position.y - divisionHeight * 0.6
        self.gameCenterButton.position.x = -(self.gameCenterButton.frame.size.width/2) * 3
        
        self.storeButton.position.y = self.gameCenterButton.position.y
        self.storeButton.position.x = (self.storeButton.frame.size.width/2) * 3
        
        self.soundButton.position.y = -self.gameCenterButton.position.y
        self.soundButton.position.x = +maxWidth/2 - 3*self.soundButton.frame.size.width/2
    }
    
    private func resizeSprite( sprite: SKSpriteNode, toFitHeight height: CGFloat ) {
        var aspectRatio = sprite.frame.size.width/sprite.frame.size.height
        sprite.size.height = height
        sprite.size.width = sprite.size.height * aspectRatio
    }
}
