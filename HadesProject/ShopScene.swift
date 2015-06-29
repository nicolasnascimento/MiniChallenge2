//
//  ShopScene.swift
//  HadesProject
//
//  Created by Gabriel Freitas on 6/26/15.
//  Copyright (c) 2015 OurCompany. All rights reserved.
//

import SpriteKit

class ShopScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        
    }
    
    func createLabels() {
        var coinsLabel = SKLabelNode(text: "Coins: 0")
        var shopLabel = SKLabelNode(text: "Shop")
        var upgradeLabel = SKLabelNode(text: "Upgrades")
        var skinsLabel = SKLabelNode(text: "Skins")
        
        
    }
    
    private func resizeLabel(label: SKLabelNode, ToFitHeight height: CGFloat) -> SKLabelNode {
        while( label.frame.size.height > height ) {
            label.fontSize *= 0.8
        }
        return label
    }
}