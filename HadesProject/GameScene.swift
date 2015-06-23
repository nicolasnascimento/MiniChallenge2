//
//  GameScene.swift
//  HadesProject
//
//  Created by Nicolas Nascimento on 02/06/15.
//  Copyright (c) 2015 OurCompany. All rights reserved.
//

import SpriteKit


@objc protocol GameSceneProtocol : NSObjectProtocol {
    
    // Required
    func gravityForLevel() -> CGVector
    func maximumAmountOfObjectsForLevel() -> Int
    //func backgroundImageName() -> String
    func groundImageName() -> String
    
    //Optional
    // This should return objects to be put in the scene after a random timer event
    optional func objectsForRound() -> [SKSpriteNode]
    // This should handle the hero's contact with a object
    optional func heroDidTouchObject(hero: Hero, object: SKSpriteNode)
    // This should finish the current level and prepare for the next one
    optional func allObjectsHaveBeenCreated()
    
}

let HERO_CATEGORY:UInt32 = 0x1 << 0
let GROUND_CATEGORY:UInt32 = 0x1 << 1
let OBSTACLE_CATEGORY:UInt32 = 0x1 << 2
let WALL_CATEGORY:UInt32 = 0x1 << 3

class GameScene: SKScene, SKPhysicsContactDelegate, GameSceneProtocol {
    // Useful constants
    let BACKGROUND_COLOR: SKColor = SKColor.orangeColor()
    let HERO_SIZE_FACTOR: CGFloat = 10
    let HERO_MASS: CGFloat = 30
    
    // Shortcuts
    var WIDTH: CGFloat { return self.view!.frame.size.width }
    var HEIGHT: CGFloat { return self.view!.frame.size.height }
    
    // IMPORTANT - All nodes should be added as child to this node
    var world: SKNode = SKNode()
    
    // Heros
    var rightHero: Hero = Hero()
    var leftHero: Hero = Hero()
    
    // Controls
    var timerNode: SKNode = SKNode()
    var amountOfObjects = 0
    
    // Touches
    var isTouching1: Bool = false
    var isTouching2: Bool = false
    
    // Ground and Roof
    var ground: SKSpriteNode = SKSpriteNode()
    var roof: SKShapeNode = SKShapeNode()
    
    // MARK - Overriden Methods
    override func didMoveToView(view: SKView) {
        self.initialize()
        self.createHeros()
        self.createGround()
        self.createRoof()
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if location.x < self.frame.width/2 {
                isTouching1 = true
            }
            
            if location.x > self.frame.width/2 {
                isTouching2 = true
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if isTouching1 && leftHero.physicsBody?.velocity.dy < HEIGHT*0.6567 {
            leftHero.physicsBody?.applyImpulse(CGVectorMake(0, 2000))
        }
        
        if (isTouching2 && rightHero.physicsBody?.velocity.dy < HEIGHT*0.6567 ) {
            rightHero.physicsBody?.applyImpulse(CGVectorMake(0, 2000))
        }
        
        if (rightHero.physicsBody?.velocity.dy < -(HEIGHT*0.8231)) {
            rightHero.physicsBody?.velocity.dy = -( HEIGHT*0.8231)
        }
        
        if (leftHero.physicsBody?.velocity.dy < -(HEIGHT*0.8231)) {
            leftHero.physicsBody?.velocity.dy = -( HEIGHT*0.8231)
        }
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if location.x < self.frame.width/2 {
                isTouching1 = false
            }

            if location.x > self.frame.width/2 {
                isTouching2 = false
            }
        }
    }
    override func didFinishUpdate() {
        for child: AnyObject in world.children {
            var node = child as! SKNode
            if node.position.x + node.frame.size.width < 0 {
                node.removeFromParent()
            }
        }
       if let body = self.leftHero.physicsBody {
            body.velocity.dx = 0
        }
        if let body = self.rightHero.physicsBody {
            body.velocity.dx = 0
        }
    }
    
    //  MARK - GameSceneProtocol Methods
    func gravityForLevel() -> CGVector {
        return CGVector(dx: 0, dy: -9.8)
    }
    func objectsForRound() -> [SKSpriteNode] {
        var obstacle = SKSpriteNode(imageNamed: "mini_ground")
        obstacle.name = "obstacle"
        obstacle.createPhysicsBodyForSelfWithCategory(OBSTACLE_CATEGORY, contactCategory: HERO_CATEGORY , collisionCategory: 0)
        obstacle.physicsBody?.affectedByGravity = false
        return [obstacle];
    }
    
    func heroDidTouchObject(hero: Hero, object: SKSpriteNode) {
        println("heroDidTouchObject")
    }
    
    func maximumAmountOfObjectsForLevel() -> Int {
        return 10;
    }
    
    func allObjectsHaveBeenCreated() {
        println("allObjectsHaveBeenCreated")
    }
    func groundImageName() -> String {
        return "four"
    }
    // MARK - Private Methods
    // One time initialization
    private func initialize() {
        self.backgroundColor = self.BACKGROUND_COLOR
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = self.gravityForLevel()
        
        self.world = SKNode()
        self.addChild(world)
        
        self.timerNode = SKNode()
        self.amountOfObjects = 0
        world.addChild(timerNode)
        
        timerNode.runAction(SKAction.waitForDuration(0.0), completion: onTimerEvent)
    }
    private func onTimerEvent() {
        if( self.amountOfObjects != self.maximumAmountOfObjectsForLevel() ) {
            var objects = self.objectsForRound()
            for (i, obj) in enumerate(objects) {
                var node: SKSpriteNode = obj as SKSpriteNode
                dispatch_async(dispatch_get_main_queue()) {
                    node.position.x = self.WIDTH + node.frame.size.width/2
                    node.position.y = CGFloat( self.randomFrom(UInt32(self.ground.size.height), max: UInt32(self.HEIGHT - node.size.height)) )
                    self.world.addChild(node)
                    node.runAction(SKAction.moveTo(CGPoint(x: -node.frame.size.width/2, y: node.position.y), duration: self.randomFrom(2, max: 4)), completion: { () -> Void in
                        node.removeFromParent()
                    })
                }
            }
            self.amountOfObjects += objects.count
            self.timerNode.runAction(SKAction.waitForDuration(self.randomFrom(1, max: 2)), completion: onTimerEvent)
        } else {
            self.allObjectsHaveBeenCreated()
        }
    }
    // Gets all Objects from a sks file
    private func createSceneFromSksFileNamed(name: String) {
        for (i, obj) in enumerate(SKScene.unarchiveFromFile(name)!.children) {
            let node = obj as! SKNode
            node.removeFromParent()
            if let nodeName = node.name {
                switch(nodeName) {
                    case "leftHero":
                        self.leftHero.position = node.position
                    case "rightHero":
                        self.rightHero.position = node.position
                    case "obstacle":
                        if let body = node.physicsBody {
                            body.categoryBitMask = OBSTACLE_CATEGORY
                            body.contactTestBitMask = HERO_CATEGORY
                            body.collisionBitMask = 0
                        }
                        world.addChild(node)
                    default :
                        println("name not mapped in swicth statement : \(nodeName)")
                }
            }
        }
    }
    private func randomFrom(min: UInt32, max: UInt32) -> Double {
        return Double(  min + arc4random_uniform(max - min) )
    }
    // Creates the Heros in the scene
    private func createHeros() {
        self.rightHero = Hero(imageNamed: "Spaceship")
        self.leftHero = Hero(imageNamed: "Spaceship")
        
        // Resize and Positionates Heros to fit Screen
        let aspectRatio = self.rightHero.frame.size.width/self.rightHero.frame.size.height
        self.rightHero.size.height = HEIGHT/HERO_SIZE_FACTOR
        self.rightHero.size.width = self.rightHero.size.height * aspectRatio
        self.leftHero.size = self.rightHero.size
        self.leftHero.position.x = leftHero.size.width
        self.leftHero.position.y = leftHero.size.height + self.ground.size.height
        self.rightHero.position.x = rightHero.size.width + leftHero.position.x + 72
        self.rightHero.position.y = leftHero.position.y
        
        // Physics Body
        self.rightHero.createPhysicsBodyForSelfWithCategory(HERO_CATEGORY, contactCategory: GROUND_CATEGORY | OBSTACLE_CATEGORY | WALL_CATEGORY, collisionCategory: GROUND_CATEGORY | WALL_CATEGORY)
        self.leftHero.createPhysicsBodyForSelfWithCategory(HERO_CATEGORY, contactCategory: GROUND_CATEGORY | OBSTACLE_CATEGORY | WALL_CATEGORY, collisionCategory: GROUND_CATEGORY | WALL_CATEGORY)
        self.rightHero.physicsBody?.mass = HERO_MASS
        self.rightHero.physicsBody?.allowsRotation = false
        self.leftHero.physicsBody?.allowsRotation = false
        self.leftHero.physicsBody?.mass = HERO_MASS
        
        
        world.addChild(self.rightHero)
        world.addChild(self.leftHero)
    }
    private func createGround() {
        self.ground = SKSpriteNode(imageNamed: self.groundImageName())
        self.ground.size.width = WIDTH
        self.ground.size.height = HEIGHT/10
        self.ground.position.x = WIDTH/2
        self.ground.createPhysicsBodyForSelfWithCategory(GROUND_CATEGORY, contactCategory: HERO_CATEGORY, collisionCategory: HERO_CATEGORY | OBSTACLE_CATEGORY )
        self.ground.physicsBody?.dynamic = false
        
        world.addChild(self.ground)
    }
    private func createRoof() {
        self.roof = SKShapeNode(path: UIBezierPath(rect: CGRect(x: 0, y: 0, width: WIDTH, height: 2)).CGPath)
        self.roof.position.y = HEIGHT
        self.roof.createPhysicsBodyForSelfWithCategory(WALL_CATEGORY, contactCategory: OBSTACLE_CATEGORY, collisionCategory:  OBSTACLE_CATEGORY, dynamic: false, affectedByGravity: false)
        self.roof.alpha = 0
        world.addChild(self.roof)
    }
    
    // MARK - Physics Delegate
    func didBeginContact(contact: SKPhysicsContact) {
        var bodyA = contact.bodyA
        var bodyB = contact.bodyB
        
        if( ( bodyA.categoryBitMask & HERO_CATEGORY != 0 ) && ( bodyB.categoryBitMask & OBSTACLE_CATEGORY != 0 ) ) {
            self.heroDidTouchObject(bodyA.node as! Hero, object: bodyB.node as! SKSpriteNode)
        }
    }
}


// Useful extensions
extension SKSpriteNode {
    func createPhysicsBodyForSelfWithCategory(category: UInt32, contactCategory: UInt32, collisionCategory: UInt32) {
        if let body = self.physicsBody {
            body.categoryBitMask = category
            body.contactTestBitMask = contactCategory
            body.collisionBitMask = collisionCategory
        } else {
            let body = SKPhysicsBody(texture: self.texture!, size: self.size)
            body.categoryBitMask = category
            body.contactTestBitMask = contactCategory
            body.collisionBitMask = collisionCategory
            body.dynamic = true
            self.physicsBody = body
        }
    }
}

extension SKShapeNode{
    
    func createPhysicsBodyForSelfWithCategory(category: UInt32, contactCategory: UInt32, collisionCategory: UInt32, dynamic: Bool = false, affectedByGravity: Bool = true) {
    if let pB = self.physicsBody{
        var newBody =  SKPhysicsBody(polygonFromPath: self.path)
        newBody.dynamic = dynamic
        newBody.categoryBitMask = category
        newBody.collisionBitMask = collisionCategory
        newBody.contactTestBitMask = contactCategory
        newBody.velocity = pB.velocity
        newBody.affectedByGravity = affectedByGravity
        self.physicsBody = newBody
        
    }else{
        self.physicsBody = SKPhysicsBody(polygonFromPath: self.path)
            if let pB = self.physicsBody {
                pB.dynamic = dynamic
                pB.categoryBitMask = category
                pB.collisionBitMask = collisionCategory
                pB.contactTestBitMask = contactCategory
                pB.affectedByGravity = affectedByGravity
            }
    }
    }
}