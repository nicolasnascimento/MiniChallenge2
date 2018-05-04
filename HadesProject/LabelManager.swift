//
//  LabelManager.swift
//  
//
//  Created by Nicolas Nascimento on 04/07/15.
//
//

import UIKit
import SpriteKit

class LabelManager: SKNode {
    let FONT_NAME = "SanFranciscoDisplay-Regular"
    var EDGE_OFFSET: CGFloat { return min(self.maxWidth, self.maxHeight)/(15*self.HEIGHT_DIVISIONS) }
    let HEIGHT_DIVISIONS: CGFloat = 8.0
    let WIDTH_DIVISIONS: CGFloat = 8.0
    let PAUSE_ICON_NAME: String = "pauseIcon"
    let MUSIC_ICON_NAME: String = "musicIcon"
    
    var maxHeight: CGFloat = 0.0
    var maxWidth: CGFloat = 0.0

    var distanceBackgroundImage: SKSpriteNode
    var distanceLabel: SKLabelNode
    var coinsLabel: SKLabelNode

    var pauseIcon: TwoStateButton
    var musicIcon: TwoStateButton
    
    init(maxHeight: CGFloat, maxWidth: CGFloat, distanceBackgroundImageName: String, initialDistanceLabelText: String, initialCoinsLabelText: String, pauseOnIconImageName: String, pauseOffIconImageName: String, initialPauseState: Bool, musicOnImageName: String, musicOffImageName: String, initialMusicState: Bool) {
        self.maxHeight = maxHeight
        self.maxWidth = maxWidth
        self.distanceBackgroundImage = SKSpriteNode(imageNamed: distanceBackgroundImageName)
        self.distanceLabel = SKLabelNode(fontNamed: FONT_NAME)
        self.distanceLabel.text = initialDistanceLabelText
        self.distanceLabel.fontSize = 128
        self.coinsLabel = SKLabelNode(fontNamed: FONT_NAME)
        self.coinsLabel.text = initialCoinsLabelText
        self.coinsLabel.fontSize = 128
        self.pauseIcon = TwoStateButton(onTextureName: pauseOnIconImageName, offTextureName: pauseOffIconImageName, initialState: initialPauseState)
        self.musicIcon = TwoStateButton(onTextureName: musicOnImageName, offTextureName: musicOffImageName, initialState: initialMusicState)
        super.init()
        self.addChild(self.distanceBackgroundImage)
        self.addChild(self.distanceLabel)
        self.addChild(self.coinsLabel)
        self.addChild(self.musicIcon)
        self.addChild(self.pauseIcon)
        
        self.resizeAndPositionate()
    }
    private func resizeAndPositionate() {
        // Constants
        let divisionHeight = maxHeight/HEIGHT_DIVISIONS
        let divisionWidth = maxWidth/WIDTH_DIVISIONS
        
        // Resize
        Util.resizeSprite(self.distanceBackgroundImage, toFitHeight: divisionHeight)
        Util.resizeSprite(self.pauseIcon, toFitHeight: divisionHeight)
        Util.resizeSprite(self.musicIcon, toFitHeight: divisionHeight)
        Util.resizeLabel(self.distanceLabel, ToFitHeight: 2.0*divisionHeight/3.0, andWidth: self.distanceBackgroundImage.size.width*0.9)
        Util.resizeLabel(self.coinsLabel, ToFitHeight: 1.0*divisionHeight/3.0, andWidth: 0.9*distanceBackgroundImage.size.width/2)
        
        // Positionate
        self.distanceBackgroundImage.position = CGPoint(x: self.distanceBackgroundImage.size.width/2, y: maxHeight - self.distanceBackgroundImage.size.height/2)
        self.distanceLabel.position = CGPoint(x: EDGE_OFFSET + self.distanceLabel.frame.size.width/2, y: maxHeight - self.distanceLabel.frame.size.height)
        self.coinsLabel.position = CGPoint(x: EDGE_OFFSET + self.coinsLabel.frame.size.width/2, y: maxHeight - self.distanceLabel.frame.size.height - 1.1*self.coinsLabel.frame.size.height)
        self.pauseIcon.position = CGPoint(x: maxWidth - self.pauseIcon.size.width/2, y: maxHeight - self.pauseIcon.size.height/2)
        self.musicIcon.position = CGPoint(x: maxWidth - self.musicIcon.size.width/2, y: self.musicIcon.size.height/2)
        self.distanceLabel.zPosition = 100
        self.coinsLabel.zPosition = 100
        self.pauseIcon.zPosition = 100
        self.musicIcon.zPosition = 100
        
        // Rename Touchable Icons
        self.pauseIcon.name = PAUSE_ICON_NAME
        self.musicIcon.name = MUSIC_ICON_NAME
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateDistanceLabelTextTo(_ value: Int) {
        self.distanceLabel.text = self.adaptStringToFitLabel(self.distanceLabel, value: value, complementaryTextForLabel: " meters")
    }
    func updateCoinLabelTextTo(_ value: Int) {
        self.coinsLabel.text = self.adaptStringToFitLabel(self.coinsLabel, value: value, complementaryTextForLabel: " coins")
    }
    // Useful Methods
    private func adaptStringToFitLabel(_ label: SKLabelNode, value: Int, complementaryTextForLabel: String ) -> String {
        var valueAsString = value.description
        var originalCharacterAmount = Int(label.text!) ?? 0
        var buffer = valueAsString + complementaryTextForLabel
        if( originalCharacterAmount > buffer.count ) {
            var spaces = String.init(repeating: " ", count: originalCharacterAmount - buffer.count)
            buffer = spaces + buffer
        }
        return buffer
    }
}
