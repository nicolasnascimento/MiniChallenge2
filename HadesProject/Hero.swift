//
//  Hero.swift
//  HadesProject
//
//  Created by Nicolas Nascimento on 03/06/15.
//  Copyright (c) 2015 OurCompany. All rights reserved.
//

import UIKit
import SpriteKit

enum Side {
    case Right, Left
}

class Hero: SKSpriteNode {
    
    var respositivitySide: Side
    var coinsCaptured: Int = 0
    
    var resizedUpSize: CGSize {
        return CGSize(width: self.originalSize.width * self.RESIZING_FACTOR, height: self.originalSize.height * self.RESIZING_FACTOR )
    }
    var resizedDownSize: CGSize {
        return CGSize(width: self.originalSize.width / self.RESIZING_FACTOR, height: self.originalSize.height / self.RESIZING_FACTOR )
    }
    var originalSize: CGSize = CGSize()
    var isResizedUp: Bool = false
    var isResizedDown: Bool = false
    let RESIZING_FACTOR: CGFloat = 1.5
    
    init(imageNamed imageName: String = "", respositivitySide: Side = .Right) {
        self.respositivitySide = respositivitySide
        let textureForImage = SKTexture(imageNamed: imageName)
        super.init(texture: textureForImage, color: UIColor.clearColor(), size: textureForImage.size())
        self.originalSize = self.size
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Power Ups
    func invertResposivitySide() {
        self.respositivitySide = self.respositivitySide == .Right ? .Left : .Right
    }
    func resizeUp() {
        self.size = self.resizedUpSize
    }
    func resizeDown() {
        self.size = self.resizedDownSize
    }
}
