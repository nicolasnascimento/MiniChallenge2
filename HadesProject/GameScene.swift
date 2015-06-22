//
//  GameScene.swift
//  HadesProject
//
//  Created by Nicolas Nascimento on 02/06/15.
//  Copyright (c) 2015 OurCompany. All rights reserved.
//

import SpriteKit

let HERO_CATEGORY: UInt32 = 0x1 << 0
let GROUND_CATEGORY: UInt32 = 0x1 << 1
let OBSTACLE_CATEGORY: UInt32 = 0x1 << 2

class GameScene: SKScene {
    // Useful constants
    let BACKGROUND_COLOR: SKColor = SKColor.orangeColor()
    
    // Shortcuts
    var WIDTH: CGFloat { return self.view!.frame.size.width }
    var HEIGHT: CGFloat { return self.view!.frame.size.height }
    
    // IMPORTANT - All nodes should be added as child to this node
    var world: SKNode = SKNode()
    
    // Heros
    var rightHero: Hero = Hero()
    var leftHero: Hero = Hero()
    
    //Controls
    var shouldMove: Bool = true
    
    // MARK - Overriden Methods
    override func didMoveToView(view: SKView) {
        self.initialize()
        self.createHeros()
        self.createSceneFromSksFileNamed("GameScene")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for (i, obj) in enumerate(touches) {
            let touch = obj as! UITouch
            self.handleTouchAtLocation(touch.locationInNode(self))
        }
    }
    override func didFinishUpdate() {
        if( shouldMove == true ) {
            println("here")
            if let body = self.leftHero.physicsBody {
                body.velocity.dx = 100
            }
            if let body = self.rightHero.physicsBody {
                body.velocity.dx = 100
            }
        }
        self.centerCameraOnNode(self.rightHero)
    }
    // MARK - Private Methods
    // One time initialization
    private func initialize() {
        self.backgroundColor = self.BACKGROUND_COLOR
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.world = SKNode()
        self.shouldMove = true
        self.addChild(world)
    }
    // Gets all Objects from a sks file
    private func createSceneFromSksFileNamed(name: String) {
        for (i, obj) in enumerate(SKScene.unarchiveFromFile(name)!.children) {
            let node = obj as! SKNode
            node.removeFromParent()
            if let nodeName = node.name {
                switch(nodeName) {
                    case "ground" :
                        if let body = node.physicsBody {
                            body.categoryBitMask = GROUND_CATEGORY
                            body.contactTestBitMask = HERO_CATEGORY
                            body.collisionBitMask = HERO_CATEGORY | OBSTACLE_CATEGORY
                        }
                        world.addChild(node)
                    case "leftHero":
                        self.leftHero.position = node.position
                    case "rightHero":
                        self.rightHero.position = node.position
                    case "obstacle":
                        if let body = node.physicsBody {
                            body.categoryBitMask = OBSTACLE_CATEGORY
                            body.contactTestBitMask = HERO_CATEGORY
                            body.collisionBitMask = GROUND_CATEGORY | HERO_CATEGORY | OBSTACLE_CATEGORY
                        }
                        world.addChild(node)
                    default :
                        println("name not mapped in swicth statement : \(nodeName)")
                }
            }
        }
    }
    // Creates the Heros in the scene
    private func createHeros() {
        self.rightHero = Hero(imageNamed: "Spaceship")
        self.leftHero = Hero(imageNamed: "Spaceship")
        
        self.rightHero.createPhysicsBodyForSelfWithCategory(HERO_CATEGORY, contactCategory: GROUND_CATEGORY, collisionCategory: GROUND_CATEGORY)
        self.leftHero.createPhysicsBodyForSelfWithCategory(HERO_CATEGORY, contactCategory: GROUND_CATEGORY, collisionCategory: GROUND_CATEGORY)
        world.addChild(self.rightHero)
        world.addChild(self.leftHero)
    }
    //IMPLEMENT
    private func handleTouchAtLocation(location: CGPoint) {
    }
    private func centerCameraOnNode(node: SKNode) {
        
        let cameraPositionInScene:CGPoint = self.convertPoint(node.position, fromNode: node.parent!)
        node.parent!.position = CGPoint(x:node.parent!.position.x - cameraPositionInScene.x - WIDTH/7, y: node.parent!.position.y - cameraPositionInScene.y)
    }
}
