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
    func backgroundImageName() -> String
    func groundImageName() -> String
    func planetName() -> String
    func messageForPopUp() -> String
    func questionForPopUp() -> TrueFalseQuestion
    
    //Optional
    // This should return objects to be put in the scene after a random timer event
    optional func objectsForRound() -> [SKSpriteNode]
    // This should handle the hero's contact with a object
    optional func heroDidTouchObject(hero: Hero, object: SKSpriteNode)
    // This should finish the current level and prepare for the next one
    optional func allObjectsHaveBeenCreated()
}

// Physics Constants
let HERO_CATEGORY:UInt32 = 0x1 << 0
let GROUND_CATEGORY:UInt32 = 0x1 << 1
let OBSTACLE_CATEGORY:UInt32 = 0x1 << 2
let WALL_CATEGORY:UInt32 = 0x1 << 3

// Level Enumeration
enum Level {
    case Earth, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto
}

class GameScene: SKScene, SKPhysicsContactDelegate, GameSceneProtocol {
    // Useful constants
    let BACKGROUND_COLOR: SKColor = SKColor.orangeColor()
    let BACKGROUND_ANIMATION_DURATION = 20.0
    let HERO_SIZE_FACTOR: CGFloat = 5
    let OBSTACLE_SIZE_FACTOR: CGFloat = 5
    let HERO_MASS: CGFloat = 30
    let FONT_NAME: String = "Helvetica"
    
    // Power Up's Probabilities(%)
    let INVERT_PROBABILITY: Double = 10.0
    let RESIZE_UP_PROBABILITY: Double = 7.5
    let RESIZE_DOWN_PROBABILTY: Double = 7.5
    let FUSION_PROBABILITY: Double = 10.0
    let INVISIBILITY_PROBABILTY: Double = 15.0
    let MULTIPLIER_PROBABILITY: Double = 25.0
    let SPACE_KING_PROBABILITY: Double = 5.0
    let COIN_MAGNET_PROBABILITY: Double = 20.0
    
    // Objects Probabilities
    let POWER_UP_PROBABILITY: Double = 20
    let COIN_PROBABILTY: Double = 70
    let OBSTACLE_PROBILITY: Double = 10
    
    // Objects Names
    let COIN_NAME = "coin"
    let OBSTACLE_NAME = "obstacle"
    let INVERT_NAME = "invert"
    let RESIZE_UP_NAME = "resizeup"
    let RESIZE_DOWN_NAME = "resizedown"
    let FUSION_NAME = "fusion"
    let INVISIBILITY_NAME = "invisibilidade"
    let MULTIPLIER_NAME = "multiplier"
    let SPACE_KING_NAME = "spaceking"
    let COIN_MAGNET_NAME = "coinmagnet"
    
    
    // Level Variable
    static var currentLevel : Level = .Earth
    
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
    
    // The Objects
    var imageNameArray: [String] { return  ["grow", "shrink", "speedup", "speeddown"] }
    
    // Touches
    var isTouchingLeft: Bool = false
    var isTouchingRight: Bool = false
    var touchArray: Set<UITouch> = Set<UITouch>()
    
    // Ground ,Roof and Background
    var ground: SKSpriteNode = SKSpriteNode()
    var roof: SKShapeNode = SKShapeNode()
    var background1: SKSpriteNode = SKSpriteNode()
    var background2: SKSpriteNode = SKSpriteNode()
    
    // Trackers
    var distanceLabel: SKLabelNode = SKLabelNode()
    var coinsLabel: SKLabelNode = SKLabelNode()
    var planetNameLabel: SKLabelNode = SKLabelNode()
    var planetGravityLabel: SKLabelNode = SKLabelNode()
    var pauseLabel: SKSpriteNode = SKSpriteNode()
    var distanceTraveled: Int = Int()
    var coinsCap: Int = Int()
    var coinsCap2: Int = Int()

    let defaults = NSUserDefaults.standardUserDefaults()
    
    // PopUp Menu
    var curiosityPopUpMenu: PopUp!
    var questionPopUpMenu: PopUp!
    
    // Actions
    var flyingAction: SKAction = SKAction()
    var runningAction: SKAction = SKAction()
    
    
    // Questions
    lazy var questions: [TrueFalseQuestion] = {
        return QuestionDatabase.questionsForPlanetNamed(self.planetName())
    }()
    var currentQuestion: TrueFalseQuestion!
    
    // MARK - Overriden Methods
    override func didMoveToView(view: SKView) {
        self.initialize()
        self.createHeros()
        self.createGround()
        self.createRoof()
        self.createLabels()
        self.createPopUpMenusInBackground()
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if location.x < self.frame.width/2 {
                isTouchingLeft = true
            }
            if location.x > self.frame.width/2 {
                isTouchingRight = true
            }
            
            self.touchArray.insert(touch as! UITouch)
            
            let node = self.nodeAtPoint(location)
            
            if( self.curiosityPopUpMenu == nil || self.questionPopUpMenu == nil ) {
                return
            }
            
            if let nodeName = node.name {
                
                if( nodeName == self.curiosityPopUpMenu.rightButtonName() && self.curiosityPopUpMenu.alpha == 1 ) {
                    // GAMBIARRA
                    GameScene.currentLevel = .Pluto
                    self.goToNextLevel()
                    
                }else if( nodeName == self.curiosityPopUpMenu.leftButtonName() && self.curiosityPopUpMenu.alpha == 1 ) {
                    self.curiosityPopUpMenu.runAction(SKAction.fadeAlphaTo(0, duration: 1), completion: { () -> Void in
                        self.curiosityPopUpMenu.hidden = true
                    })
                    self.questionPopUpMenu.hidden = false
                    self.questionPopUpMenu.runAction(SKAction.fadeAlphaTo(1, duration: 1))
                    
                }else if( nodeName == self.questionPopUpMenu.leftButtonName() && self.questionPopUpMenu.alpha == 1 ) {
                    if( currentQuestion.answer == true ) {
                        println("right answer")
                    }else{
                        println("wrong answer")
                    }
                    
                }else if( node.name == self.questionPopUpMenu.rightButtonName() && self.questionPopUpMenu.alpha == 1 ) {
                    if( currentQuestion.answer == true ) {
                        println("wrong answer")
                    }else{
                        println("right answer")
                    }
                    
                    
                }
            }
        }
    }
    override func update(currentTime: CFTimeInterval) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.timerNode.runAction(SKAction.waitForDuration(0.05), completion: self.updateScore)
        }
        // Game is Running
        if( rightHero.hasActions() || leftHero.hasActions() ){
            
            if( rightHero.actionForKey("flying") == nil && !rightHero.isHittingTheGround ) {
                rightHero.removeActionForKey("running")
                rightHero.runAction(self.flyingAction, withKey: "flying")
            }else if( rightHero.actionForKey("running") == nil && rightHero.isHittingTheGround ) {
                rightHero.removeActionForKey("flying")
                rightHero.runAction(self.runningAction, withKey: "running")
            }
            
            if( leftHero.actionForKey("flying") == nil && !leftHero.isHittingTheGround  ) {
                leftHero.removeActionForKey("running")
                leftHero.runAction(self.flyingAction, withKey: "flying")
            }else if( leftHero.actionForKey("running") == nil && leftHero.isHittingTheGround ) {
                leftHero.removeActionForKey("flying")
                leftHero.runAction(self.runningAction, withKey: "running")
            }
            
            // Normal touch handling
            if( rightHero.respositivitySide == .Right ) {
                
                if (isTouchingRight && rightHero.physicsBody?.velocity.dy < HEIGHT*0.6567 ) {
                    rightHero.physicsBody?.applyImpulse(CGVectorMake(0, 2000))
                }
                if isTouchingLeft && leftHero.physicsBody?.velocity.dy < HEIGHT*0.6567 {
                    leftHero.physicsBody?.applyImpulse(CGVectorMake(0, 2000))
                }
                // Inverted touch handling
            } else {
                if (isTouchingLeft && rightHero.physicsBody?.velocity.dy < HEIGHT*0.6567 ) {
                    rightHero.physicsBody?.applyImpulse(CGVectorMake(0, 2000))
                }
                if isTouchingRight && leftHero.physicsBody?.velocity.dy < HEIGHT*0.6567 {
                    leftHero.physicsBody?.applyImpulse(CGVectorMake(0, 2000))
                }
            }
            
            // Determines maximum falling speed
            if (rightHero.physicsBody?.velocity.dy < -(HEIGHT*0.8231)) {
                //rightHero.physicsBody?.velocity.dy = -( HEIGHT*0.8231)
                rightHero.physicsBody?.affectedByGravity = false
            }else if( rightHero.physicsBody?.affectedByGravity == false ) {
                rightHero.physicsBody?.affectedByGravity = true
            }
            
            if (leftHero.physicsBody?.velocity.dy < -(HEIGHT*0.8231)) {
                //leftHero.physicsBody?.velocity.dy = -( HEIGHT*0.8231)
                leftHero.physicsBody?.affectedByGravity = false
            }else if( leftHero.physicsBody?.affectedByGravity == false ) {
                leftHero.physicsBody?.affectedByGravity = true
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if let index = self.touchArray.indexOf(touch as! UITouch) {
                let oldTouch = self.touchArray[ index ] as UITouch
                let newLocation = touch.locationInNode(self)
                let oldLocation = oldTouch.previousLocationInNode(self)
                
               // println("\(newLocation) , \(oldLocation)")
                
                if( oldLocation.x < self.frame.width/2 && newLocation.x > self.frame.width/2 ) {
                    isTouchingLeft = false
                    isTouchingRight = true
                } else if( oldLocation.x > self.frame.width/2 && newLocation.x < self.frame.width/2 ) {
                    isTouchingLeft = true
                    isTouchingRight = false
                }
                
                self.touchArray.insert(touch as! UITouch)
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if location.x < self.frame.width/2 {
                isTouchingLeft = false
            }
            if location.x > self.frame.width/2 {
                isTouchingRight = false
            }
            touchArray.remove(touch as! UITouch)
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
        var obstacle: SKSpriteNode
        var probability1 = arc4random_uniform(100)
        
        if( probability1 < UInt32( self.POWER_UP_PROBABILITY ) ) {
            var probability = Double(arc4random_uniform(1000))/10.0
            
            obstacle = SKSpriteNode(imageNamed: "mini_ground")
            
            if( probability < 100 && probability >= 75 ) {
                obstacle.name = MULTIPLIER_NAME
                
            } else if( probability < 75 && probability >= 55 ) {
                obstacle.name = COIN_MAGNET_NAME
                
            } else if( probability < 55 && probability >= 40 ) {
                obstacle.name = INVISIBILITY_NAME
                
            } else if( probability < 40 && probability >= 30 ) {
                obstacle.name = FUSION_NAME
                
            } else if( probability < 30 && probability >= 20 ) {
                obstacle.name = INVERT_NAME
                
            } else if( probability < 20 && probability >= 12.5 ) {
                obstacle.name = RESIZE_UP_NAME
                
            } else if( probability < 12.5 && probability >= 5 ) {
                obstacle.name = RESIZE_DOWN_NAME
                
            } else {
                obstacle.name = SPACE_KING_NAME
            }
            
        } else if( probability1 > UInt32( self.POWER_UP_PROBABILITY ) && probability1 < UInt32( self.POWER_UP_PROBABILITY + self.COIN_PROBABILTY ) ) {
            
            obstacle = SKSpriteNode(imageNamed: "coinIcon")
            obstacle.name = COIN_NAME
        } else {
            
            obstacle = SKSpriteNode(imageNamed: imageNameArray[ Int(arc4random_uniform(3)) ])
            obstacle.name = OBSTACLE_NAME
        }
        
        obstacle.createPhysicsBodyForSelfWithCategory(OBSTACLE_CATEGORY, contactCategory: HERO_CATEGORY , collisionCategory: 0)
        obstacle.physicsBody?.affectedByGravity = false
        return [obstacle];
    }
    
    func heroDidTouchObject(hero: Hero, object: SKSpriteNode) {
        if( object.parent == nil ) {
            return
        }
        
        if( hero.shouldHitObjects ) {
            object.removeFromParent()
            
            if( object.name == OBSTACLE_NAME ) {
                println(OBSTACLE_NAME)
                self.showRestartPopUp()
                
            }else if( object.name == MULTIPLIER_NAME ) {
                println(MULTIPLIER_NAME)
                hero.doubleCoinMultiplier()
                
            }else if( object.name == COIN_MAGNET_NAME ) {
                println(COIN_MAGNET_NAME)
                hero.activateCoinMagnet()
                
            }else if( object.name == INVISIBILITY_NAME ) {
                println(INVISIBILITY_NAME)
                hero.turnToInvisible()
                
            }else if( object.name == FUSION_NAME ) {
                println(FUSION_NAME)
                
            }else if( object.name == INVERT_NAME ) {
                println(INVERT_NAME)
                rightHero.invertResposivitySide()
                leftHero.invertResposivitySide()
                
            }else if( object.name == RESIZE_UP_NAME ) {
                println(RESIZE_UP_NAME)
                hero.resizeUp()
                
            }else if( object.name == RESIZE_DOWN_NAME ) {
                println(RESIZE_DOWN_NAME)
                hero.resizeDown()
                
            }else if( object.name == SPACE_KING_NAME ) {
                println(SPACE_KING_NAME)
            }
        }
        
        if( object.name == COIN_NAME ) {

            if let coins = defaults.integerForKey("coinsCaptured") as? Int{
                    coinsCap = coins + hero.coinMultiplier
                    defaults.setObject(coinsCap, forKey: "coinsCaptured")
            }
            self.coinsLabel.text = String(format: "%ld coins", defaults.integerForKey("coinsCaptured"))
        }
    }
    
    func maximumAmountOfObjectsForLevel() -> Int {
        return 10;
    }
    
    func allObjectsHaveBeenCreated() {
        self.goToNextLevel()
    }
    func groundImageName() -> String {
        return "four"
    }
    func backgroundImageName() -> String {
        return "four"
    }
    func planetName() -> String {
        return "Not A Planet"
    }
    func messageForPopUp() -> String {
        return "Nicolas is the God"
    }
    func questionForPopUp() -> TrueFalseQuestion {
        return TrueFalseQuestion(planetName: "Earth", question: "Is Nicolas The God?", answer: true)
    }
    // MARK - Private Methods
    // One time initialization
    private func initialize() {
        self.backgroundColor = self.BACKGROUND_COLOR
        self.currentQuestion = self.questionForPopUp()
        
        self.amountOfObjects = 0
        
        self.physicsWorld.gravity = self.gravityForLevel()
        
        self.physicsWorld.contactDelegate = self
        
        self.world = SKNode()
        self.addChild(world)
        
        self.createBackgroundImage()
        
        self.timerNode = SKNode()
        timerNode.runAction(SKAction.waitForDuration(0.0), completion: onTimerEvent)
        
        world.addChild(timerNode)
    }
    
    private func goToNextLevel() {
        var viewSize = CGSize(width: WIDTH, height: HEIGHT)
        var nextPlanet: GameScene
        
        switch( GameScene.currentLevel ) {
        case .Earth:
            GameScene.currentLevel = .Moon
            nextPlanet = MoonLevel(size: viewSize) as GameScene
            //println("moon")
        case .Moon:
            GameScene.currentLevel = .Mercury
            nextPlanet = MercuryLevel(size: viewSize) as GameScene
            //println("mercury")
        case .Mercury:
            GameScene.currentLevel = .Venus
            nextPlanet = VenusLevel(size: viewSize) as GameScene
            //println("venus")
        case .Venus:
            GameScene.currentLevel = .Mars
            nextPlanet = MarsLevel(size: viewSize) as GameScene
            //println("mars")
        case .Mars:
            GameScene.currentLevel = .Jupiter
            nextPlanet = JupiterLevel(size: viewSize) as GameScene
            //println("jupiter")
        case .Jupiter:
            GameScene.currentLevel = .Saturn
            nextPlanet = SaturnLevel(size: viewSize) as GameScene
            //println("Saturn")
        case .Saturn:
            GameScene.currentLevel = .Uranus
            nextPlanet = UranusLevel(size: viewSize) as GameScene
            //println("Uranus")
        case .Uranus:
            GameScene.currentLevel = .Neptune
            nextPlanet = NeptuneLevel(size: viewSize) as GameScene
            //println("Neptune")
        case .Neptune:
            GameScene.currentLevel = .Pluto
            nextPlanet = PlutoLevel(size: viewSize)
            //println("Pluto")
        default :
            GameScene.currentLevel = .Earth
            nextPlanet = EarthLevel(size: viewSize)
            //println("earth")
        }
        nextPlanet.scaleMode = .AspectFill
        self.view?.presentScene(nextPlanet, transition: SKTransition.fadeWithDuration(1))
    }
    private func createBackgroundImage() {
        self.background1 = SKSpriteNode(imageNamed: self.backgroundImageName())
        self.background2 = SKSpriteNode(imageNamed: self.backgroundImageName())
        self.adaptBackground(self.background1)
        self.adaptBackground(self.background2)
        self.background2.position.x += (self.background2.size.width*0.99)
        
        self.background1.runAction(SKAction.moveToX(-self.background1.size.width/2 , duration: BACKGROUND_ANIMATION_DURATION), completion: onMovementFinish)
        self.background2.runAction(SKAction.moveToX(-self.background1.size.width/2 + self.background2.size.width, duration: BACKGROUND_ANIMATION_DURATION*0.99))
        
        world.addChild(self.background1)
        world.addChild(self.background2)
        self.background1.zPosition = -1
        self.background2.zPosition = -1
    }
    
    private func onMovementFinish() {
        
        self.background1.removeAllActions()
        self.background1.removeFromParent()
        self.background1 = self.background2
        self.background2 = SKSpriteNode(imageNamed: self.backgroundImageName())
        self.adaptBackground(self.background2)
        self.background2.position.x += (self.background2.size.width*0.99)
        self.world.addChild(self.background2)

        
        // if necessary uncommment
        dispatch_async(dispatch_get_main_queue()) {
            self.background1.zPosition = -1
            self.background2.zPosition = -1
            self.background1.runAction(SKAction.moveToX(-self.background1.size.width/2, duration: self.BACKGROUND_ANIMATION_DURATION), completion: self.onMovementFinish)
            self.background2.runAction(SKAction.moveToX(-self.background1.size.width/2 + self.background2.size.width, duration: self.BACKGROUND_ANIMATION_DURATION*0.99))
        }
    }
    
    private func adaptBackground( background: SKSpriteNode ) {
        if( background.size.width > background.size.height ) {
            let aspectRatio = background.size.width / background.size.height
            background.size.height = HEIGHT
            background.size.width = background.size.height * aspectRatio
        } else {
            let aspectRatio = background.size.height / background.size.width
            background.size.width = WIDTH
            background.size.height = background.size.width * aspectRatio
        }
        
        background.position.y = background.size.height/2
        background.position.x = background.size.width/2
    }
    private func onTimerEvent() {
        
        if( self.amountOfObjects != self.maximumAmountOfObjectsForLevel() && self.rightHero.hasActions() && self.leftHero.hasActions() ) {
            var objects = self.objectsForRound()
            for (i, obj) in enumerate(objects) {
                var node: SKSpriteNode = obj as SKSpriteNode
                let aspectRatio =  node.size.width/node.size.height
                node.size.height = HEIGHT/OBSTACLE_SIZE_FACTOR
                node.size.width = node.size.height * aspectRatio
                node.physicsBody = nil
                node.createPhysicsBodyForSelfWithCategory(OBSTACLE_CATEGORY, contactCategory: HERO_CATEGORY , collisionCategory: 0)
                node.physicsBody?.dynamic = true
                node.physicsBody?.affectedByGravity = false
                node.physicsBody?.mass = 2
                if( node.name == COIN_NAME ) {
                    node.physicsBody?.charge = 10000000
                }
                dispatch_async(dispatch_get_main_queue()) {
                    node.position.x = self.WIDTH + node.frame.size.width/2
                    node.position.y = CGFloat( self.randomFrom(UInt32(self.ground.size.height + node.size.height/2), max: UInt32(self.HEIGHT - node.size.height/2)) )
                    //println("node.position.y = \(node.position.y)")
                    self.world.addChild(node)
                    
                    node.runAction(SKAction.moveTo(CGPoint(x: -node.frame.size.width/2, y: node.position.y), duration: self.randomFrom(2, max: 4)), completion: { () -> Void in
                        node.removeFromParent()
                    })
                }
            }
            self.amountOfObjects += objects.count
            self.timerNode.runAction(SKAction.waitForDuration(self.randomFrom(1, max: 2)), completion: onTimerEvent)
        } else if( self.rightHero.hasActions() && self.leftHero.hasActions() ){
            self.allObjectsHaveBeenCreated()
        }
    }
    
    private func updateScore() {
        if( rightHero.hasActions() || leftHero.hasActions() ){
            if let score = defaults.integerForKey("distanceTraveled") as? Int {
                distanceTraveled = score + 1
                self.distanceLabel.text = String(format: "%ld meters", arguments: [ (self.distanceTraveled)])
                defaults.setObject(distanceTraveled, forKey: "distanceTraveled")
            }
        }

    }
    // Gets objects from a sks file
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
        //Animate Heros
        var textureArray: [SKTexture] = [SKTexture]()
        var textureAtlas = SKTextureAtlas(named: "AstronautRun")
        
        for i in 1 ... textureAtlas.textureNames.count {
            var textureName = String(format: "astro%d", arguments: [i])
            var texture = textureAtlas.textureNamed(textureName)
            textureArray.append(texture)
        }
        
        self.rightHero = Hero(texture: textureArray[0] as SKTexture, respositivitySide: .Right)
        self.leftHero = Hero(texture: textureArray[0] as SKTexture, respositivitySide: .Left)
        
        self.loadFlyingTexturesInBackground()
        self.runningAction = SKAction.repeatActionForever(SKAction.animateWithTextures(textureArray, timePerFrame: 0.1))
        
        self.rightHero.runAction(self.runningAction)
        self.leftHero.runAction(self.runningAction)
        
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
        self.rightHero.createPhysicsBodyForSelfWithCategory(HERO_CATEGORY, contactCategory: GROUND_CATEGORY | OBSTACLE_CATEGORY | WALL_CATEGORY, collisionCategory: GROUND_CATEGORY | WALL_CATEGORY, squaredBody: true)
        self.leftHero.createPhysicsBodyForSelfWithCategory(HERO_CATEGORY, contactCategory: GROUND_CATEGORY | OBSTACLE_CATEGORY | WALL_CATEGORY, collisionCategory: GROUND_CATEGORY | WALL_CATEGORY, squaredBody: true)
        self.rightHero.physicsBody?.mass = HERO_MASS
        self.rightHero.physicsBody?.allowsRotation = false
        self.leftHero.physicsBody?.allowsRotation = false
        self.leftHero.physicsBody?.mass = HERO_MASS
        
        world.addChild(self.rightHero)
        world.addChild(self.leftHero)
    }
    private func loadFlyingTexturesInBackground() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            var flyingTextures = [SKTexture]()
            var flyingAtlas = SKTextureAtlas(named: "AstronautFly")
            
            for i in 0 ..< flyingAtlas.textureNames.count {
                var texture = flyingAtlas.textureNamed(flyingAtlas.textureNames[i] as! String)
                flyingTextures.append(texture)
            }
            println("here")
            self.flyingAction = SKAction.repeatActionForever(SKAction.animateWithTextures(flyingTextures, timePerFrame: 0.1))
        }
    }
    private func createGround() {
        self.ground = SKSpriteNode(imageNamed: self.groundImageName())
        self.ground.size.width = WIDTH
        self.ground.size.height = HEIGHT/10
        self.ground.position.x = WIDTH/2
        self.ground.createPhysicsBodyForSelfWithCategory(GROUND_CATEGORY, contactCategory: HERO_CATEGORY, collisionCategory: HERO_CATEGORY | OBSTACLE_CATEGORY )
        self.ground.physicsBody?.dynamic = false
        self.ground.alpha = 0.0
        
        world.addChild(self.ground)
    }
    private func createRoof() {
        self.roof = SKShapeNode(path: UIBezierPath(rect: CGRect(x: 0, y: 0, width: WIDTH, height: 2)).CGPath)
        self.roof.position.y = HEIGHT
        self.roof.createPhysicsBodyForSelfWithCategory(WALL_CATEGORY, contactCategory: OBSTACLE_CATEGORY, collisionCategory:  OBSTACLE_CATEGORY, dynamic: false, affectedByGravity: false)
        self.roof.alpha = 0
        world.addChild(self.roof)
    }
    
    private func createLabels() {
        // Initialization
        self.distanceLabel = SKLabelNode(fontNamed: FONT_NAME)
        self.coinsLabel = SKLabelNode(fontNamed: FONT_NAME)
        self.planetNameLabel = SKLabelNode(fontNamed: FONT_NAME)
        self.planetGravityLabel = SKLabelNode(fontNamed: FONT_NAME)
        // self.pauseLabel = SKSpriteNode(imageNamed: <#String#>)
        
        // Initial Values
        self.distanceLabel.text = String(format: "%ld meters", arguments: [ (self.distanceTraveled)])
        self.coinsLabel.text = String(format: "%ld coins", arguments: [ (self.defaults.integerForKey("coinsCaptured"))])
        self.planetNameLabel.text = self.planetName() + ":"
        self.planetGravityLabel.text = String(format: "%.2lf", arguments: [(-self.gravityForLevel().dy)])
        
        // Resize
        self.distanceLabel = self.resizeLabel(distanceLabel, ToFitHeight: HEIGHT/20)
        self.coinsLabel = self.resizeLabel(coinsLabel, ToFitHeight: HEIGHT/30)
        self.planetNameLabel = self.resizeLabel(planetNameLabel, ToFitHeight: HEIGHT/10)
        self.planetGravityLabel = self.resizeLabel(planetGravityLabel, ToFitHeight: HEIGHT/10)
        
        // Add to Scene
        world.addChild(self.distanceLabel)
        world.addChild(self.coinsLabel)
        world.addChild(self.planetNameLabel)
        world.addChild(self.planetGravityLabel)
        
        // Positions
        self.distanceLabel.position = CGPoint(x: (self.distanceLabel.frame.size.width/1.123456789) , y: HEIGHT - self.distanceLabel.frame.size.height)
        self.coinsLabel.position = CGPoint(x: self.coinsLabel.frame.size.width/1.123456789 , y: self.distanceLabel.position.y - self.distanceLabel.frame.size.height)
        self.planetNameLabel.position = CGPoint(x: WIDTH/2 - self.planetNameLabel.frame.size.width/2, y: HEIGHT - self.planetNameLabel.frame.size.height)
        self.planetGravityLabel.position = CGPoint(x: WIDTH/2 + self.planetGravityLabel.frame.size.width/2, y: self.planetNameLabel.position.y)
        //self.distanceLabel.horizontalAlignmentMode = .Left
        //self.coinsLabel.horizontalAlignmentMode = .Left
        
    }
    
    private func resizeLabel(label: SKLabelNode, ToFitHeight height: CGFloat) -> SKLabelNode {
        while( label.frame.size.height > height ) {
            label.fontSize *= 0.8
        }
        return label
    }
    private func createPopUpMenusInBackground() {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            
            println("1")
            self.curiosityPopUpMenu = PopUp(backgroundImageName: "loseBackground", rightButtonImageName: "restartIcon", leftButtonImageName: "questionIcon", distance: "1334", planetName: self.planetName(), message: self.messageForPopUp())
            self.curiosityPopUpMenu.size = CGSize(width: self.WIDTH * 0.75, height: self.HEIGHT * 0.75)
            self.curiosityPopUpMenu.position = CGPoint(x: self.WIDTH/2, y: self.HEIGHT/2)
            self.curiosityPopUpMenu.alpha = 0
            self.curiosityPopUpMenu.hidden = true
            
            println("2")
            self.questionPopUpMenu = PopUp(backgroundImageName: "loseBackground", rightButtonImageName: "falseIcon", leftButtonImageName: "trueIcon", distance: "1334", planetName: self.planetName(), message: self.questionForPopUp().question)
            self.questionPopUpMenu.size = self.curiosityPopUpMenu.size
            self.questionPopUpMenu.position = self.curiosityPopUpMenu.position
            self.questionPopUpMenu.alpha = 0
            self.questionPopUpMenu.hidden = true
            
            self.world.addChild(self.curiosityPopUpMenu)
            self.world.addChild(self.questionPopUpMenu)
        }
    }
    
    private func showRestartPopUp() {
        if( curiosityPopUpMenu != nil ) {
            self.curiosityPopUpMenu.hidden = false
            self.curiosityPopUpMenu.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.5))
        }
        
        println("here")
        
        self.background1.removeAllActions()
        self.background2.removeAllActions()
        self.rightHero.removeAllActions()
        self.leftHero.removeAllActions()
    }
    
    // MARK - Physics Delegate
    func didBeginContact(contact: SKPhysicsContact) {
        var bodyA = contact.bodyA
        var bodyB = contact.bodyB
        
        if( ( bodyA.categoryBitMask & HERO_CATEGORY  != 0 ) && ( bodyB.categoryBitMask & GROUND_CATEGORY != 0 ) ) {
            if( bodyA.node == nil || bodyB.node == nil ) {
                println("physics body is not connected to a node")
            }else{
                var hero = bodyA.node as! Hero
                hero.isHittingTheGround = true
            }
        }
        
        if( ( bodyA.categoryBitMask & HERO_CATEGORY != 0 ) && ( bodyB.categoryBitMask & OBSTACLE_CATEGORY != 0 ) ) {
            
            if( bodyA.node == nil || bodyB.node == nil ) {
                println("physics body is not connected to a node")
            }else {
                self.heroDidTouchObject(bodyA.node as! Hero, object: bodyB.node as! SKSpriteNode)
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        var bodyA = contact.bodyA
        var bodyB = contact.bodyB
        
        if( ( bodyA.categoryBitMask & HERO_CATEGORY  != 0 ) && ( bodyB.categoryBitMask & GROUND_CATEGORY != 0 ) ) {
            if( bodyA.node == nil || bodyB.node == nil ) {
                println("physics body is not connected to a node")
            }else{
                var hero = bodyA.node as! Hero
                hero.isHittingTheGround = false
            }
        }
    }
}

// Useful extensions
extension SKSpriteNode {

    func createPhysicsBodyForSelfWithCategory(category: UInt32, contactCategory: UInt32, collisionCategory: UInt32, squaredBody: Bool = false) {
        
        if let body = self.physicsBody {
            body.categoryBitMask = category
            body.contactTestBitMask = contactCategory
            body.collisionBitMask = collisionCategory
        } else {
            var body: SKPhysicsBody
            if( squaredBody ) {
                body = SKPhysicsBody(rectangleOfSize: self.frame.size, center: CGPoint(x: 0, y: -self.frame.size.height*0.1))
            }else {
                body = SKPhysicsBody(texture: self.texture, size: self.frame.size)
            }
            body.categoryBitMask = category
            body.contactTestBitMask = contactCategory
            body.collisionBitMask = collisionCategory
            body.dynamic = true
            body.allowsRotation = false
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