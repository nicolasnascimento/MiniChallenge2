//
//  ShopScene.swift
//  HadesProject
//
//  Created by Gabriel Freitas on 6/26/15.
//  Copyright (c) 2015 OurCompany. All rights reserved.
//

import SpriteKit

class ShopScene: SKScene {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
    }
    
    func createLabels() {
        var coinsLabel = SKLabelNode(text: "Coins: 0")
        var shopLabel = SKLabelNode(text: "Shop")
        var upgradeLabel = SKLabelNode(text: "Upgrades")
        var skinsLabel = SKLabelNode(text: "Skins")
    }
}
