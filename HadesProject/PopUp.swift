//
//  PopUp.swift
//  
//
//  Created by Nicolas Nascimento on 29/06/15.
//
//

import UIKit
import SpriteKit

class PopUp: SKSpriteNode {
    
    override var size: CGSize {
        didSet {
            self.positionate()
        }
    }
    
    let FONT_NAME = "Heuvetica"
    let DIVISIONS: CGFloat = 5.0
    let ANIMATION_DURATION: Double = 1
    let BUTTON_DISTANCE_FRACTION: CGFloat = 1.2
    
    var rightButtonImage: SKSpriteNode
    var leftButtonImage: SKSpriteNode
    
    var distanceLabel: SKLabelNode
    var planetNameLabel: SKLabelNode
    var messageLabel: SKLabelNode
    
    init(backgroundImageName: String, rightButtonImageName: String, leftButtonImageName: String, distance: String, planetName: String, message: String) {
        self.rightButtonImage = SKSpriteNode(imageNamed: rightButtonImageName)
        self.rightButtonImage.name = "rightButtonName"
        self.leftButtonImage = SKSpriteNode(imageNamed: leftButtonImageName)
        self.leftButtonImage.name = "leftButtonName"
        
        self.distanceLabel = SKLabelNode(fontNamed: self.FONT_NAME)
        self.planetNameLabel = SKLabelNode(fontNamed: self.FONT_NAME)
        self.messageLabel = SKLabelNode(fontNamed: self.FONT_NAME)
        
        let aTexture = SKTexture(imageNamed: backgroundImageName)
        super.init(texture: aTexture, color: UIColor.clearColor(), size: aTexture.size())
        
        self.distanceLabel.text = distance
        self.planetNameLabel.text = planetName
        self.messageLabel.text = message
        
        self.addChild(rightButtonImage)
        self.addChild(leftButtonImage)
        self.addChild(distanceLabel)
        self.addChild(planetNameLabel)
        self.addChild(messageLabel)
        
        self.positionate()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func rightButtonName() -> String {
        return rightButtonImage.name!
    }
    func leftButtonName() -> String {
        return leftButtonImage.name!
    }
    
    private func positionate() {
        var divisionHeight = self.size.height/self.DIVISIONS
        self.planetNameLabel.position.y = 2 * divisionHeight
        self.distanceLabel.position.y = 1 * divisionHeight
        self.messageLabel.position.y = 0 * divisionHeight
        self.rightButtonImage.position.y = -1 * divisionHeight
        self.leftButtonImage.position.y = -1 * divisionHeight
        self.resizeLabel(self.planetNameLabel, ToFitHeight: divisionHeight, andWidth: self.size.width )
        self.resizeLabel(self.distanceLabel, ToFitHeight: divisionHeight, andWidth: self.size.width)
        self.resizeLabel(self.messageLabel, ToFitHeight: divisionHeight, andWidth: self.size.width)
        self.resizeSprite(self.rightButtonImage, toFitHeight: divisionHeight)
        self.resizeSprite(self.leftButtonImage, toFitHeight: divisionHeight)
        self.rightButtonImage.position.x = +(BUTTON_DISTANCE_FRACTION)*(self.rightButtonImage.frame.size.width/2)
        self.leftButtonImage.position.x = -(BUTTON_DISTANCE_FRACTION)*(self.leftButtonImage.frame.size.width/2)
    }
    private func resizeSprite( sprite: SKSpriteNode, toFitHeight height: CGFloat ) {
        var aspectRatio = sprite.size.width/sprite.size.height
        sprite.size.height = height
        sprite.size.width = sprite.size.height * aspectRatio
    }
    private func resizeLabel(label: SKLabelNode, ToFitHeight height: CGFloat, andWidth width: CGFloat) -> SKLabelNode {
        while( label.frame.size.height > height || label.frame.size.width > width ) {
            label.fontSize *= 0.5
        }
        label.fontColor = SKColor.blackColor()
        label.horizontalAlignmentMode = .Center
        label.verticalAlignmentMode = .Center
        return label
    }
}
