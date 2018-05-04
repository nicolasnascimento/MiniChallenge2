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
    
    let FONT_NAME = "SanFranciscoDisplay-Regular"
    let DIVISIONS: CGFloat = 5.0
    let ANIMATION_DURATION: Double = 1
    let BUTTON_DISTANCE_FRACTION: CGFloat = 1.5
    
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
        super.init(texture: aTexture, color: UIColor.clear, size: aTexture.size())
        
        self.distanceLabel.text = distance
        self.planetNameLabel.text = planetName
        self.messageLabel.text = message
        
        self.distanceLabel.color = SKColor.black
        self.planetNameLabel.color = SKColor.black
        self.messageLabel.color = SKColor.black
        
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
        var divisionWidth = self.size.width/self.DIVISIONS
        self.planetNameLabel.position.y = 1 * divisionHeight
        
        self.messageLabel.position.y = -divisionHeight/2
        self.rightButtonImage.position.y = -2.5 * divisionHeight
        self.leftButtonImage.position.y = -2.5 * divisionHeight
        Util.resizeLabel(self.planetNameLabel, ToFitHeight: divisionHeight, andWidth: self.size.width )
        Util.resizeLabel(self.distanceLabel, ToFitHeight: divisionHeight, andWidth: self.size.width)
        Util.resizeLabel(self.messageLabel, ToFitHeight: divisionHeight, andWidth: self.size.width)
        Util.resizeSprite(self.rightButtonImage, toFitHeight: divisionHeight)
        Util.resizeSprite(self.leftButtonImage, toFitHeight: divisionHeight)
        self.rightButtonImage.position.x = +(BUTTON_DISTANCE_FRACTION)*(self.rightButtonImage.frame.size.width/2)
        self.leftButtonImage.position.x = -(BUTTON_DISTANCE_FRACTION)*(self.leftButtonImage.frame.size.width/2)
        self.planetNameLabel.position.x = -1.25*divisionWidth
        self.planetNameLabel.position.y += self.planetNameLabel.frame.size.height/2
        self.distanceLabel.position.y = self.planetNameLabel.position.y
        self.distanceLabel.position.x = -self.planetNameLabel.position.x
        
        self.distanceLabel.zPosition = 50
        self.planetNameLabel.zPosition = 50
        self.rightButtonImage.zPosition = 50
        self.leftButtonImage.zPosition = 50
    }
}
