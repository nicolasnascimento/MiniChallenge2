//
//  GameScene.swift
//  HadesProject
//
//  Created by Nicolas Nascimento on 02/06/15.
//  Copyright (c) 2015 OurCompany. All rights reserved.
//

import SpriteKit
import AVFoundation

@objc protocol GameSceneProtocol : NSObjectProtocol {
    
    // Required
    func gravityForLevel() -> CGVector
    func maximumAmountOfObjectsForLevel() -> Int
    func backgroundImageName() -> String
    func groundImageName() -> String
    func planetName() -> String
    func messageForPopUp() -> String
    func questionForPopUp() -> TrueFalseQuestion
    func transactionImageName() -> String
    func popUpBackgroundImageName()-> String
    
    //Optional
    // This should return objects to be put in the scene after a random timer event
    @objc optional func objectsForRound() -> [SKSpriteNode]
    // This should handle the hero's contact with a object
    @objc optional func heroDidTouchObject(hero: Hero, object: SKSpriteNode)
    // This should finish the current level and prepare for the next one
    @objc optional func allObjectsHaveBeenCreated()
    // This tell whether the level needs a start menu
    @objc optional func shouldPresentStartMenu() -> Bool
}

// Physics Constants
let HERO_CATEGORY:UInt32 = 0x1 << 0
let GROUND_CATEGORY:UInt32 = 0x1 << 1
let OBSTACLE_CATEGORY:UInt32 = 0x1 << 2
let WALL_CATEGORY:UInt32 = 0x1 << 3
let PORTAL_CATEGORY:UInt32 = 0x1 << 4

// Level Enumeration
enum Level {
    case Earth, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto
}

class GameScene: SKScene, SKPhysicsContactDelegate, GameSceneProtocol {
    // Useful constants
    let BACKGROUND_COLOR: SKColor = SKColor.orange
    let BACKGROUND_ANIMATION_DURATION = 3.0
    let HERO_SIZE_FACTOR: CGFloat = 3.5
    let OBSTACLE_SIZE_FACTOR: CGFloat = 10
    let HERO_MASS: CGFloat = 30
    let FONT_NAME: String = "SanFranciscoDisplay-Regular"
    let TRANSACTION_ANIMATION_DURATION: Double = 2
    let PORTAL_IMAGE_NAME: String = "portal"
    
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
    let COIN_PROBABILTY: Double = 20
    let OBSTACLE_PROBILITY: Double = 80
    
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
    lazy var WIDTH: CGFloat = { return self.view!.frame.size.width }()
    lazy var HEIGHT: CGFloat = { return self.view!.frame.size.height }()
    
    // IMPORTANT - All nodes should be added as child to this node
    var world: SKNode = SKNode()
    
    // Heros
    var rightHero: Hero = Hero()
    var leftHero: Hero = Hero()
    
    // Controls
    var timerNode: SKNode = SKNode()
    var player: AVAudioPlayer!
    var amountOfObjects = 0
    var gameHasBegun : Bool = false
    var objects: [SKSpriteNode]! = [SKSpriteNode]()
    var objectsInScreen: Int = 0
    
    // The Objects
    var imageNameArray: [String] { return  ["grow", "shrink", "speedup", "speeddown"] }
    
    // Touches
    var isTouchingLeft: Bool = false
    var isTouchingRight: Bool = false
    var touchArray: Set<UITouch> = Set<UITouch>()
    
    // Ground ,Roof, Background and Transaction
    var ground: SKSpriteNode! = nil
    var roof: SKShapeNode! = nil
    var background: BackgroundManager! = nil
    var transaction: SKSpriteNode! = nil
    
    // Trackers
    var labels: LabelManager! = nil
    var distanceTraveled: Int = 0
    var coinsCap: Int = 0
    var coinsCap2: Int = 0

    let defaults = UserDefaults.standard
    
    // PopUp Menu
    var curiosityPopUpMenu: PopUp!
    var questionPopUpMenu: PopUp!
    
    // Actions
    var flyingAction: SKAction! = SKAction()
    var runningAction: SKAction! = SKAction()
    
    // Menu
    var menu: StartMenu! = nil
    
    // Portal
    var portal: SKSpriteNode = SKSpriteNode()
    
    // Questions
    lazy var questions: [TrueFalseQuestion] = {
        return QuestionDatabase.questionsForPlanetNamed(self.planetName())
    }()
    
    lazy var facts: [TrueFalseQuestion] = {
        return QuestionDatabase.factsForPlanetNamed(self.planetName())
        }()
    var currentQuestion: TrueFalseQuestion!
    
    // MARK - Overriden Methods
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.initialize()
        if( self.shouldPresentStartMenu() ) {
            self.createStartMenu()
        }
        // High Priority
        self.createGround()
        self.createRoof()
        self.createHeros()
        self.createLabels()
        self.createSounds()
        self.createTransactionImage(inBackground: false)
        
        // This can run in background
        self.createPopUpMenusInBackground()
        self.createPortalInBackground()
        
        if( !self.shouldPresentStartMenu() ) {
            self.runGame()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if( !gameHasBegun ) {
            self.runGame()
            return
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if location.x < self.frame.width/2 {
                isTouchingLeft = true
            }
            if location.x > self.frame.width/2 {
                isTouchingRight = true
            }
            
            self.touchArray.insert(touch)
            
            let node = self.atPoint(location)
            
            if let nodeName = node.name {
                if( nodeName == self.labels.PAUSE_ICON_NAME ) {
                    self.labels.pauseIcon.changeState()
                    if( self.labels.pauseIcon.state == true ) {
                        self.showPausePopUp()
                    }else{
                        self.hidePausePopUp()
                    }
                } else if( nodeName == self.labels.MUSIC_ICON_NAME ) {
                   // println("should switch music")
                    self.labels.musicIcon.changeState()
                    if( self.player.isPlaying ) {
                        self.player.pause()
                    }else{
                        self.player.play()
                    }
                }
            }else if( self.curiosityPopUpMenu == nil || self.questionPopUpMenu == nil ) {
                return
            }
            
            if let nodeName = node.name {
                
                if( nodeName == self.curiosityPopUpMenu.rightButtonName() && self.curiosityPopUpMenu.alpha == 1 ) {
                    // GAMBIARRA
                    defaults.set(0, forKey: "distanceTraveled")
                    GameScene.currentLevel = .Pluto
                    self.goToNextLevel()
                    
                }else if( nodeName == self.curiosityPopUpMenu.leftButtonName() && self.curiosityPopUpMenu.alpha == 1 ) {
                    self.curiosityPopUpMenu.run(SKAction.fadeAlpha(to: 0, duration: 1), completion: { [unowned self] () -> Void in
                        self.curiosityPopUpMenu.isHidden = true
                    })
                    self.questionPopUpMenu.isHidden = false
                    self.questionPopUpMenu.run(SKAction.fadeAlpha(to: 1, duration: 1))
                    
                }else if( nodeName == self.questionPopUpMenu.leftButtonName() && self.questionPopUpMenu.alpha == 1 ) {
                    if( currentQuestion.answer == true ) {
                       // println("right answer")
                        self.restartGameFromPopUpAnswer()
                        
                    }else{
                        // GAMBIARRA
                        defaults.set(0, forKey: "distanceTraveled")
                        GameScene.currentLevel = .Pluto
                        
                        self.goToNextLevel()
                    }
                    
                }else if( node.name == self.questionPopUpMenu.rightButtonName() && self.questionPopUpMenu.alpha == 1 ) {
                    if( currentQuestion.answer == false ) {
                        //println("right answer")
                        self.restartGameFromPopUpAnswer()
                    }else{
                        // GAMBIARRA
                        defaults.set(0, forKey: "distanceTraveled")
                        GameScene.currentLevel = .Pluto
                        self.goToNextLevel()
                    }
                }
            }
        }
    }
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if( gameHasBegun && self.timerNode.action(forKey: "updateScore") == nil && self.curiosityPopUpMenu != nil && self.curiosityPopUpMenu.isHidden == true ) {
            //DispatchQueue.main.async {
            var action = SKAction.wait(forDuration: 0.2)
            var updateScore = SKAction.customAction(withDuration: 0.0, actionBlock: { [unowned self] (node, duration) -> Void in
                self.updateScore()
            })
            self.timerNode.run(SKAction.sequence([action, updateScore]), withKey: "updateScore")
            //}
        }
        // Game is Running
        if( !rightHero.isPaused && !leftHero.isPaused ){
            
            if( rightHero.action(forKey:"flying") == nil && !rightHero.isHittingTheGround ) {
                rightHero.removeAction(forKey: "running")
                rightHero.run(self.flyingAction, withKey: "flying")
            }else if( rightHero.action(forKey:"running") == nil && rightHero.isHittingTheGround ) {
                rightHero.removeAction(forKey:"flying")
                rightHero.run(self.runningAction, withKey: "running")
            }
            
            if( leftHero.action(forKey:"flying") == nil && !leftHero.isHittingTheGround  ) {
                leftHero.removeAction(forKey: "running")
                leftHero.run(self.flyingAction, withKey: "flying")
            }else if( leftHero.action(forKey:"running") == nil && leftHero.isHittingTheGround ) {
                leftHero.removeAction(forKey: "flying")
                leftHero.run(self.runningAction, withKey: "running")
            }
            
            if( rightHero.isFused || leftHero.isFused ) {
                if( ( isTouchingRight || isTouchingLeft ) && leftHero.physicsBody!.velocity.dy < HEIGHT*0.6567 ) {
                    leftHero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2000))
                }
                
                self.rightHero.position = self.leftHero.position
            
            // Normal touch handling
            }else if( rightHero.respositivitySide == .Right ) {
                
                if (isTouchingRight && rightHero.physicsBody!.velocity.dy < HEIGHT*0.6567 ) {
                    rightHero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2000))
                }
                if isTouchingLeft && leftHero.physicsBody!.velocity.dy < HEIGHT*0.6567 {
                    leftHero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2000))
                }
                // Inverted touch handling
            } else {
                if (isTouchingLeft && rightHero.physicsBody!.velocity.dy < HEIGHT*0.6567 ) {
                    rightHero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2000))
                }
                if isTouchingRight && leftHero.physicsBody!.velocity.dy < HEIGHT*0.6567 {
                    leftHero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2000))
                }
            }
            
            // Determines maximum falling speed
            if (rightHero.physicsBody!.velocity.dy < -(HEIGHT*0.8231)) {
                //rightHero.physicsBody?.velocity.dy = -( HEIGHT*0.8231)
                rightHero.physicsBody?.affectedByGravity = false
            }else if( rightHero.physicsBody?.affectedByGravity == false ) {
                rightHero.physicsBody?.affectedByGravity = true
            }
            
            if (leftHero.physicsBody!.velocity.dy < -(HEIGHT*0.8231)) {
                //leftHero.physicsBody?.velocity.dy = -( HEIGHT*0.8231)
                leftHero.physicsBody?.affectedByGravity = false
            }else if( leftHero.physicsBody?.affectedByGravity == false ) {
                leftHero.physicsBody?.affectedByGravity = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        for touch in touches {
            if let index = self.touchArray.index(of: touch) {
                let oldTouch = self.touchArray[ index ] as UITouch
                let newLocation = touch.location(in: self)
                let oldLocation = oldTouch.previousLocation(in: self)
                
               // println("\(newLocation) , \(oldLocation)")
                
                if( oldLocation.x < self.frame.width/2 && newLocation.x > self.frame.width/2 ) {
                    isTouchingLeft = false
                    isTouchingRight = true
                } else if( oldLocation.x > self.frame.width/2 && newLocation.x < self.frame.width/2 ) {
                    isTouchingLeft = true
                    isTouchingRight = false
                }
                
                self.touchArray.insert(touch)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.touchArray.removeAll(keepingCapacity: false)
        self.isTouchingLeft = false
        self.isTouchingRight = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            if location.x < self.frame.width/2 {
                isTouchingLeft = false
            }
            if location.x > self.frame.width/2 {
                isTouchingRight = false
            }
            touchArray.remove(touch as! UITouch)
        }
        if( touchArray.isEmpty ) {
            self.isTouchingRight = false
            self.isTouchingLeft = false
        }
    }
    override func didFinishUpdate() {
        for child in world.children {
            var node = child
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
        
        return self.getRandomObject()
    }
    
    func heroDidTouchObject(_ hero: Hero, object: SKSpriteNode) {
        if( object.parent == nil ) {
            return
        }
        
        if( hero.shouldHitObjects ) {
            object.removeFromParent()
            
            if( object.name == OBSTACLE_NAME ) {
                //println(OBSTACLE_NAME)
                
                self.run(SKAction.playSoundFileNamed("explosion.mp3.mp3", waitForCompletion: true))
                self.showRestartPopUp()
                
                
            }else if( object.name == MULTIPLIER_NAME ) {
                //println(MULTIPLIER_NAME)
                hero.doubleCoinMultiplier()

            }else if( object.name == COIN_MAGNET_NAME ) {
                //println(COIN_MAGNET_NAME)
                hero.activateCoinMagnet()
                
            }else if( object.name == INVISIBILITY_NAME ) {
                //println(INVISIBILITY_NAME)
                hero.turnToInvisible()
                
            }else if( object.name == FUSION_NAME ) {
                //println(FUSION_NAME)
                self.leftHero.fuseWithHero(self.rightHero)
                
            }else if( object.name == INVERT_NAME ) {
                //println(INVERT_NAME)
                rightHero.invertResposivitySide()
                leftHero.invertResposivitySide()
                
            }else if( object.name == RESIZE_UP_NAME ) {
                //println(RESIZE_UP_NAME)
                hero.resizeUp()
                
            }else if( object.name == RESIZE_DOWN_NAME ) {
                //println(RESIZE_DOWN_NAME)
                hero.resizeDown()
                
            }else if( object.name == SPACE_KING_NAME ) {
                //println(SPACE_KING_NAME)
                hero.turnToSpaceKing()

            }
        }
        
        if( object.name == COIN_NAME ) {
            
            if( object.parent != nil ){
                object.removeFromParent()
            }
            
            hero.run(SKAction.playSoundFileNamed("coinBlink.m4a", waitForCompletion: true))

            if let coins = defaults.integer(forKey: "coinsCaptured") as? Int{
                coinsCap = coins + hero.coinMultiplier
                defaults.set(coinsCap, forKey: "coinsCaptured")
            }
            //self.labels.coinsLabel.text = String(format: "%ld coins", defaults.integerForKey("coinsCaptured"))
            self.labels.updateCoinLabelTextTo(defaults.integer(forKey: "coinsCaptured"))
        }
    }
    
    func maximumAmountOfObjectsForLevel() -> Int {
        return 10;
    }
    
    func allObjectsHaveBeenCreated() {
        
        defaults.set(distanceTraveled, forKey: "score")
        
        if( self.portal.isHidden == true ) {
            self.portal.alpha = 1
            self.portal.isHidden = false
            self.world.addChild(self.portal)
            self.portal.run( SKAction.move(to: CGPoint(x: -self.portal.frame.size.width/2, y: self.HEIGHT/2), duration:BACKGROUND_ANIMATION_DURATION))
        }
        //self.goToNextLevel()
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
        return "The Spirits Are Restless"
    }
    func questionForPopUp() -> TrueFalseQuestion {
        return TrueFalseQuestion(planetName: "Earth", question: "Are the Spirits Restless ?", answer: true)
    }
    func transactionImageName() -> String {
        return "Transition Earth"
    }
    func popUpBackgroundImageName() -> String {
        return "Game Over " + self.planetName()
    }
    func shouldPresentStartMenu() -> Bool {
        return false
    }
    // MARK - Private Methods
    // One time initialization
    private func initialize() {
        self.backgroundColor = self.BACKGROUND_COLOR
        self.currentQuestion = self.questionForPopUp()
        //defaults.set(0, forKey: "distanceTraveled")
        self.amountOfObjects = 0
        self.gameHasBegun = self.shouldPresentStartMenu() ? false : true
        
        self.physicsWorld.gravity = self.gravityForLevel()
        
        self.physicsWorld.contactDelegate = self
        
        self.world = SKNode()
        self.addChild(world)
        
        self.createBackgroundImage()
        
        self.timerNode = SKNode()
        
        if( self.gameHasBegun ) {
            self.timerNode.run(SKAction.wait(forDuration:0.0), completion: self.onTimerEvent)
        }
        
        self.world.addChild(timerNode)
    }
    
    private func getRandomObject() -> [SKSpriteNode] {
        var obstacle: SKSpriteNode
        var probability1 = arc4random_uniform(100)
        
        if( self.leftHero.isSpaceKing || self.rightHero.isSpaceKing ) {
            obstacle = SKSpriteNode(imageNamed: "coinIcon")
            obstacle.name = COIN_NAME
            
        } else if( probability1 < UInt32( self.POWER_UP_PROBABILITY ) ) {
            var probability = Double(arc4random_uniform(1000))/10.0
            
            if( probability < 100 && probability >= 75 ) {
                obstacle = SKSpriteNode(imageNamed: "MultiplierCoinsPowerUpIcon")
                obstacle.name = MULTIPLIER_NAME
                
            } else if( probability < 75 && probability >= 55 ) {
                obstacle = SKSpriteNode(imageNamed: "CoinMagnetPowerUp")
                obstacle.name = COIN_MAGNET_NAME
                
            } else if( probability < 55 && probability >= 40 ) {
                obstacle = SKSpriteNode(imageNamed: "GhostPowerUp")
                obstacle.name = INVISIBILITY_NAME
                
            } else if( probability < 40 && probability >= 30 ) {
                obstacle = SKSpriteNode(imageNamed: "FusionPowerUp")
                obstacle.name = FUSION_NAME
                
            } else if( probability < 30 && probability >= 20 ) {
                obstacle = SKSpriteNode(imageNamed: "ChangeSidePowerUp")
                obstacle.name = INVERT_NAME
                
            } else if( probability < 20 && probability >= 12.5 ) {
                obstacle = SKSpriteNode(imageNamed: "GrowUpPowerUp")
                obstacle.name = RESIZE_UP_NAME
                
            } else if( probability < 12.5 && probability >= 5 ) {
                obstacle = SKSpriteNode(imageNamed: "SizeDownPowerUp")
                obstacle.name = RESIZE_DOWN_NAME
                
            } else {
                obstacle = SKSpriteNode(imageNamed: "SpaceKingPowerUp")
                obstacle.name = SPACE_KING_NAME
            }
            
        } else if( probability1 > UInt32( self.POWER_UP_PROBABILITY ) && probability1 < UInt32( self.POWER_UP_PROBABILITY + self.COIN_PROBABILTY ) ) {
            
            switch(arc4random_uniform(4)){
            case 0:
                obstacle = SKSpriteNode(imageNamed: "coinIcon")
                obstacle.name = COIN_NAME
            case 1:
                return self.createCoinsFromSksFileNamed("CoinLine")
            case 2:
                return self.createCoinsFromSksFileNamed("CoinU")
            case 3:
                return self.createCoinsFromSksFileNamed("CoinH")
            default:
                obstacle = SKSpriteNode(imageNamed: "coinIcon")
                obstacle.name = COIN_NAME
            }
            
            
        } else {
            obstacle = SKSpriteNode(imageNamed: imageNameArray[ Int(arc4random_uniform( UInt32(self.imageNameArray.count))) ])
            obstacle.name = OBSTACLE_NAME
        }
        
        return [obstacle];
    }
    
    private func runGame() {
        let moveHalfLeft = SKAction.moveTo(x: WIDTH/2, duration: TRANSACTION_ANIMATION_DURATION/6)
        let wait = SKAction.wait(forDuration:TRANSACTION_ANIMATION_DURATION/2)
        let moveOtherHalfLeft = SKAction.moveTo(x: 0, duration: TRANSACTION_ANIMATION_DURATION/6)
        
        if( menu != nil ) {
            self.menu.run(SKAction.fadeAlpha(to: 0, duration: 0.5), completion: { [unowned self] () -> Void in
                
                DispatchQueue.main.async {
                    
                    if( self.transaction.parent == nil ) {
                        self.world.addChild(self.transaction)
                        self.transaction.run(SKAction.sequence([moveHalfLeft, wait, moveOtherHalfLeft]), completion: { [unowned self] () -> Void in
                            
                            self.timerNode.run(SKAction.wait(forDuration:0.0), completion: self.onTimerEvent)
                            self.gameHasBegun = true
                            self.menu.removeFromParent()
                            self.menu = nil
                            self.transaction.removeFromParent()
                            self.transaction = nil
                        })
                    }
                }
            })
        }else{
            if( self.transaction.parent == nil ) {
                DispatchQueue.main.async {
                    self.world.addChild(self.transaction)
                    self.transaction.run(SKAction.sequence([moveHalfLeft, wait, moveOtherHalfLeft]), completion: { [unowned self] () -> Void in
                        
                        self.timerNode.run(SKAction.wait(forDuration:0.0), completion: self.onTimerEvent)
                        self.gameHasBegun = true
                        self.transaction.removeFromParent()
                        self.transaction = nil
                    })
                }
            }
        }
        
    }
    private func goToNextLevel() {
        if( self.player != nil ) {
            self.player.pause()
        }
        var viewSize = CGSize(width: WIDTH, height: HEIGHT)
        var nextPlanet: GameScene
        
        switch( GameScene.currentLevel ) {
        case .Earth:
            GameScene.currentLevel = .Moon
            nextPlanet = MoonLevel(size: viewSize) as GameScene
        case .Moon:
            GameScene.currentLevel = .Mercury
            nextPlanet = MercuryLevel(size: viewSize) as GameScene
        case .Mercury:
            GameScene.currentLevel = .Venus
            nextPlanet = VenusLevel(size: viewSize) as GameScene
        case .Venus:
            GameScene.currentLevel = .Mars
            nextPlanet = MarsLevel(size: viewSize) as GameScene
        case .Mars:
            GameScene.currentLevel = .Jupiter
            nextPlanet = JupiterLevel(size: viewSize) as GameScene
        case .Jupiter:
            GameScene.currentLevel = .Saturn
            nextPlanet = SaturnLevel(size: viewSize) as GameScene
        case .Saturn:
            GameScene.currentLevel = .Uranus
            nextPlanet = UranusLevel(size: viewSize) as GameScene
        case .Uranus:
            GameScene.currentLevel = .Neptune
            nextPlanet = NeptuneLevel(size: viewSize) as GameScene
        case .Neptune:
            GameScene.currentLevel = .Pluto
            nextPlanet = PlutoLevel(size: viewSize)
        default :
            GameScene.currentLevel = .Earth
            nextPlanet = EarthLevel(size: viewSize)
        }
        nextPlanet.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration:1)
        self.ground.removeFromParent()
        self.roof.removeFromParent()
        self.labels.removeFromParent()
        nextPlanet.ground = self.ground
        nextPlanet.roof = self.roof
        nextPlanet.labels = self.labels
        nextPlanet.player = self.player
        
        DispatchQueue.main.async {
            
            self.view?.presentScene(nextPlanet, transition:transition)
            self.world.removeAllChildren()
            self.unload()
        }
        
    }
    private func createBackgroundImage() {
        self.background = BackgroundManager(firstLevelImageName: "first" + self.planetName(), secondLevelImageName: "second" + self.planetName(), thirdLevelImageName: "third" + self.planetName(), fourthLevelImageName: "fourth" + self.planetName(), maxHeight: HEIGHT, maxWidth: WIDTH)
        self.background.zPosition = -100
        self.world.addChild(background)
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
        
        if( self.amountOfObjects < self.maximumAmountOfObjectsForLevel() && !self.rightHero.isPaused && !self.leftHero.isPaused ) {
            if( self.objects == nil ) {
                self.objects = self.objectsForRound()
            }
            for (i, obj) in objects.enumerated() {
//                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                DispatchQueue.global(qos: .userInitiated).async {
                    var node: SKSpriteNode = obj as SKSpriteNode
                    let aspectRatio =  node.size.width/node.size.height
                    node.size.height = self.HEIGHT/self.OBSTACLE_SIZE_FACTOR
                    node.size.width = node.size.height * aspectRatio
                    node.physicsBody = nil
                    node.createPhysicsBodyForSelfWithCategory(OBSTACLE_CATEGORY, contactCategory: HERO_CATEGORY , collisionCategory: 0)
                    node.physicsBody?.isDynamic = true
                    node.physicsBody?.affectedByGravity = false
                    node.physicsBody?.mass = 2
                    var duration = self.BACKGROUND_ANIMATION_DURATION
                    if( node.position.x != 0 ) {
                        duration = Double(CGFloat(self.BACKGROUND_ANIMATION_DURATION)*(self.WIDTH + node.position.x)/self.WIDTH)
                    }
                    node.position.x += self.WIDTH + node.size.width/2
                    if( node.name != "coinFromSKS" ) {
                        node.position.y = CGFloat( self.randomFrom(min: UInt32(self.ground.size.height + node.size.height/2), max: UInt32(self.HEIGHT - node.size.height/2)) )
                    }else if( node.name == "coinFromSKS"){
                        node.name = self.COIN_NAME
                    }
                    DispatchQueue.main.async {
                        self.world.addChild(node)
                        
                        node.run(SKAction.move(to:CGPoint(x: -node.frame.size.width/2, y: node.position.y), duration: duration), completion: { () -> Void in
                            node.removeFromParent()
                        })
                    }
                }
            }
            
            
            self.amountOfObjects += objects.count
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            DispatchQueue.global(qos: .background).async {
                self.objects = self.objectsForRound()
            }
            self.objects = nil
            self.timerNode.run(SKAction.wait(forDuration:self.randomFrom(min: 1, max: 3)), completion: onTimerEvent)
        } else if( !self.rightHero.isPaused && !self.leftHero.isPaused  ){
            self.allObjectsHaveBeenCreated()
        }
    }
    
    private func updateScore() {
        if( !self.rightHero.isPaused && !self.leftHero.isPaused ){
            if let score = defaults.integer(forKey: "distanceTraveled") as? Int {
                distanceTraveled = score + 1
                //DispatchQueue.main.async {
                    self.labels.updateDistanceLabelTextTo(self.distanceTraveled)
                //}
                defaults.set(distanceTraveled, forKey: "distanceTraveled")
            }
        }

    }
    // Gets objects from a sks file
    func createCoinsFromSksFileNamed(_ name: String) -> [SKSpriteNode] {
        var coins = [SKSpriteNode]()
        for (i, obj) in SKScene.unarchiveFromFile(file: name)!.children.enumerated() {
            let node = obj as! SKNode
            node.removeFromParent()
            if let nodeName = node.name {
                if( nodeName == "coin" && node is SKSpriteNode ){
                    node.physicsBody?.categoryBitMask = OBSTACLE_CATEGORY
                    node.physicsBody?.collisionBitMask = 0
                    node.physicsBody?.contactTestBitMask = HERO_CATEGORY
                    node.name = "coinFromSKS"
                    coins.append(node as! SKSpriteNode)
                }
            }
        }
        return coins
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
        
        self.runningAction = SKAction.repeatForever(SKAction.animate(with: textureArray, timePerFrame: 0.1))
        
        self.rightHero.run(self.runningAction)
        self.leftHero.run(self.runningAction)
        
        // Resize and Positionates Heros to fit Screen
        let aspectRatio = self.rightHero.frame.size.width/self.rightHero.frame.size.height
        self.rightHero.size.height = HEIGHT/HERO_SIZE_FACTOR
        self.rightHero.size.width = self.rightHero.size.height * aspectRatio
        self.leftHero.size = self.rightHero.size
        self.leftHero.position.x = leftHero.size.width
        self.leftHero.position.y = leftHero.size.height + self.ground.size.height
        self.rightHero.position.x = rightHero.size.width + leftHero.position.x
        self.rightHero.position.y = leftHero.position.y
        
        // Physics Body
        self.rightHero.createPhysicsBodyForSelfWithCategory(HERO_CATEGORY, contactCategory: GROUND_CATEGORY | OBSTACLE_CATEGORY | WALL_CATEGORY | PORTAL_CATEGORY, collisionCategory: GROUND_CATEGORY | WALL_CATEGORY, squaredBody: true)
        self.leftHero.createPhysicsBodyForSelfWithCategory(HERO_CATEGORY, contactCategory: GROUND_CATEGORY | OBSTACLE_CATEGORY | WALL_CATEGORY | PORTAL_CATEGORY, collisionCategory: GROUND_CATEGORY | WALL_CATEGORY, squaredBody: true)
        self.rightHero.physicsBody?.mass = HERO_MASS
        self.rightHero.physicsBody?.allowsRotation = false
        self.leftHero.physicsBody?.allowsRotation = false
        self.rightHero.physicsBody?.restitution = 0
        self.leftHero.physicsBody?.restitution = 0
        self.leftHero.physicsBody?.mass = HERO_MASS
        
        world.addChild(self.rightHero)
        world.addChild(self.leftHero)
    }
    private func loadFlyingTexturesInBackground() {
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
        DispatchQueue.global(qos: .background).async {
            var flyingTextures = [SKTexture]()
            var flyingAtlas = SKTextureAtlas(named: "AstronautFly")
            
            for i in 0 ..< flyingAtlas.textureNames.count {
                var texture = flyingAtlas.textureNamed(flyingAtlas.textureNames[i] as! String)
                flyingTextures.append(texture)
            }
            self.flyingAction = SKAction.repeatForever(SKAction.animate(with: flyingTextures, timePerFrame: 0.1))
        }
    }
    private func createGround() {
        if( self.ground == nil ) {
            self.ground = SKSpriteNode(imageNamed: self.groundImageName())
            self.ground.size.width = WIDTH
            self.ground.size.height = HEIGHT/5
            self.ground.position.x = WIDTH/2
            self.ground.createPhysicsBodyForSelfWithCategory(GROUND_CATEGORY, contactCategory: HERO_CATEGORY, collisionCategory: HERO_CATEGORY | OBSTACLE_CATEGORY )
            self.ground.physicsBody?.restitution = 0.0
            self.ground.physicsBody?.isDynamic = false
            self.ground.alpha = 0.0
        }
        
        world.addChild(self.ground)
    }
    private func createRoof() {
        if( self.roof == nil ) {
            self.roof = SKShapeNode(path: UIBezierPath(rect: CGRect(x: 0, y: 0, width: WIDTH, height: 2)).cgPath)
            self.roof.position.y = HEIGHT
            self.roof.createPhysicsBodyForSelfWithCategory(WALL_CATEGORY, contactCategory: OBSTACLE_CATEGORY, collisionCategory:  OBSTACLE_CATEGORY, dynamic: false, affectedByGravity: false)
            self.roof.alpha = 0
        }
        world.addChild(self.roof)
    }
    
    private func createLabels() {
        if( self.labels == nil ) {
            self.labels = LabelManager(
                maxHeight: HEIGHT,
                maxWidth: WIDTH,
                distanceBackgroundImageName: "distance",
                initialDistanceLabelText: "00000 meters",
                initialCoinsLabelText: "0000 coins",
                pauseOnIconImageName: "play",
                pauseOffIconImageName: "pause",
                initialPauseState: false,
                musicOnImageName: "music",
                musicOffImageName: "no music",
                initialMusicState: false
            )
        }
        self.labels.updateCoinLabelTextTo(defaults.integer(forKey: "coinsCaptured"))
        self.world.addChild(self.labels)
    }
    
    private func createPopUpMenusInBackground() {
        
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
        DispatchQueue.global(qos: .userInitiated).async {
           // println("1 - Pup")
            self.curiosityPopUpMenu = PopUp(backgroundImageName: self.popUpBackgroundImageName(), rightButtonImageName: "restartIcon", leftButtonImageName: "questionIcon", distance: "00000 m", planetName: self.planetName(), message: self.messageForPopUp())
            var height = self.HEIGHT * 0.75
            var width = self.getWidthForSpriteWithOriginalHeight(self.curiosityPopUpMenu.size.height, andOriginalWidth: self.curiosityPopUpMenu.size.width, andNewHeight: height)
            self.curiosityPopUpMenu.size = CGSize(width: width, height: height)
            self.curiosityPopUpMenu.position = CGPoint(x: self.WIDTH/2, y: self.HEIGHT/2)
            self.curiosityPopUpMenu.alpha = 0
            self.curiosityPopUpMenu.isHidden = true
            self.curiosityPopUpMenu.zPosition = 10
            
            self.currentQuestion = self.questionForPopUp()
            self.questionPopUpMenu = PopUp(backgroundImageName: self.popUpBackgroundImageName(), rightButtonImageName: "falseIcon", leftButtonImageName: "trueIcon", distance: "00000 m", planetName: self.planetName(), message: self.currentQuestion.question)
            self.questionPopUpMenu.size = self.curiosityPopUpMenu.size
            self.questionPopUpMenu.position = self.curiosityPopUpMenu.position
            self.questionPopUpMenu.alpha = 0
            self.questionPopUpMenu.isHidden = true
            self.questionPopUpMenu.zPosition = 10
            
            self.world.addChild(self.curiosityPopUpMenu)
            self.world.addChild(self.questionPopUpMenu)
            //println("2 - Pup")
        }
    }
    
    private func getWidthForSpriteWithOriginalHeight(_ originalHeight: CGFloat, andOriginalWidth originalWidth: CGFloat, andNewHeight newHeight: CGFloat ) -> CGFloat {
        return newHeight * originalWidth/originalHeight
    }
    
    private func showPausePopUp() {
        if( curiosityPopUpMenu != nil ) {
            self.timerNode.removeAllActions()
            self.removeCoinsAndObjects()
            self.curiosityPopUpMenu.isHidden = false
            self.curiosityPopUpMenu.rightButtonImage.isHidden = true
            self.curiosityPopUpMenu.leftButtonImage.isHidden = true
            
//            self.curiosityPopUpMenu.distanceLabel.text = self.labels.distanceLabel.text.substringWithRange(Range<String.Index>(start: self.labels.distanceLabel.text.startIndex, end: advance(self.labels.distanceLabel.text.endIndex, -5)))
            self.curiosityPopUpMenu.run(SKAction.fadeAlpha(to: 1.0, duration: 0.5))
        }
        
        self.rightHero.isPaused = true
        self.leftHero.isPaused = true
    }
    private func hidePausePopUp() {
        if( curiosityPopUpMenu != nil ) {
            self.curiosityPopUpMenu.isHidden = true
            self.curiosityPopUpMenu.alpha = 0
        }
        self.leftHero.isPaused = false
        self.rightHero.isPaused = false
        
       // println("restarting game from pause")
        self.timerNode.run(SKAction.wait(forDuration:0.0), completion: self.onTimerEvent)
    }
    
    private func showRestartPopUp() {
        if( curiosityPopUpMenu != nil ) {
           // println("here3")
            self.curiosityPopUpMenu.isHidden = false
            self.curiosityPopUpMenu.rightButtonImage.isHidden = false
            self.curiosityPopUpMenu.leftButtonImage.isHidden = false
//            self.curiosityPopUpMenu.distanceLabel.text = self.labels.distanceLabel.text.substringWithRange(Range<String.Index>(start: self.labels.distanceLabel.text.startIndex, end: advance(self.labels.distanceLabel.text.endIndex, -5)))
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.questionPopUpMenu.distanceLabel.text = self.curiosityPopUpMenu.distanceLabel.text
            }
            self.curiosityPopUpMenu.run(SKAction.fadeAlpha(to: 1.0, duration: 0.5))
        }
        
        self.removeCoinsAndObjects()
        
        self.leftHero.restoreOriginalPhysicsProperties()
        self.rightHero.restoreOriginalPhysicsProperties()
        
        self.rightHero.isPaused = true
        self.leftHero.isPaused = true
    }
    private func removeCoinsAndObjects() {
//        self.world.enumerateChildNodesWithName(OBSTACLE_NAME, usingBlock: { [unowned self] (node, error) -> Void in
        self.world.enumerateChildNodes(withName: OBSTACLE_NAME) { [unowned self] (node, error) -> Void in
            if( self.amountOfObjects > 0 ) {
                self.amountOfObjects -= 1
            }
            node.removeFromParent()
        }
        self.world.enumerateChildNodes(withName: COIN_NAME) { [unowned self] (node, error) -> Void in
            if( self.amountOfObjects > 0 ) {
                self.amountOfObjects -= 1
            }
            node.removeFromParent()
        }
        self.world.enumerateChildNodes(withName: "portal") { [unowned self] (node, error) -> Void in
            if( self.amountOfObjects > 0 ) {
                self.amountOfObjects -= 1
            }
            node.removeFromParent()
        }
        
    }
    private func createStartMenu() {
        self.menu = StartMenu(playButtonImageName: "logoPlanetDash", gameCenterButtonImageName: "ranking", storeButtonImageName: "store")
        world.addChild(self.menu)
        self.menu.startAnimating(HEIGHT, maxWidth: WIDTH)
        self.menu.position = CGPoint(x: WIDTH/2, y: HEIGHT/2)
        self.menu.zPosition = 1
    }
    
    private func restartGameFromPopUpAnswer() {
        self.questionPopUpMenu.run(SKAction.fadeAlpha(to: 0, duration: 1), completion: { [unowned self] () -> Void in
            self.questionPopUpMenu.removeFromParent()
            self.curiosityPopUpMenu.removeFromParent()
            self.questionPopUpMenu = nil
            self.curiosityPopUpMenu = nil
            self.createPopUpMenusInBackground()
            self.timerNode.run(SKAction.wait(forDuration:0.0), completion: self.onTimerEvent)
            self.gameHasBegun = true
            self.rightHero.isPaused = false
            self.leftHero.isPaused = false
        })
        
    }
    private func createTransactionImage( inBackground: Bool = false ) {
        
        if( inBackground ) {
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            DispatchQueue.global(qos: .userInitiated).async {
               // println("1-TI")
                self.transaction = SKSpriteNode(imageNamed: self.transactionImageName())
                Util.resizeSprite(self.transaction, toFitHeight: self.HEIGHT/2)
                self.transaction.position.y = self.HEIGHT/2
                self.transaction.position.x = self.WIDTH
                
                //self.world.addChild(self.transaction)
               // println("2-TI")
            }
        }else{
          //  println("1-TI")
                self.transaction = SKSpriteNode(imageNamed: self.transactionImageName())
                Util.resizeSprite(self.transaction, toFitHeight: self.HEIGHT/2)
                self.transaction.position.y = self.HEIGHT/2
                self.transaction.position.x = self.WIDTH
                
                //self.world.addChild(self.transaction)
             //   println("2-TI")
        }
    }
    private func createSounds() {
        if( self.player == nil ) {
            var url = Bundle.main.url(forResource: "GameMusic", withExtension: "m4a")
//            var error: NSErrorPointer! = NSErrorPointer()
            self.player = try! AVAudioPlayer(contentsOf: url!)
            self.player.numberOfLoops = -1
            self.player.prepareToPlay()
            self.player.play()
        }else if( !self.player.isPlaying ) {
            self.player.play()
        }
    }
    private func createPortalInBackground() {
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
        DispatchQueue.global(qos: .background).async {
            self.portal = SKSpriteNode(imageNamed: self.PORTAL_IMAGE_NAME)
            Util.resizeSprite(self.portal, toFitHeight: self.HEIGHT)
            self.portal.createPhysicsBodyForSelfWithCategory(PORTAL_CATEGORY, contactCategory: HERO_CATEGORY, collisionCategory: 0, squaredBody: true)
            self.portal.name = "portal"
            self.portal.physicsBody?.affectedByGravity = false
            self.portal.position.x = self.WIDTH + self.portal.size.width/2
            self.portal.position.y = self.HEIGHT/2
            self.portal.alpha = 0
            self.portal.isHidden = true
        }
    }
    private func unload() {
//        if( self.player != nil ) {
//            self.player.stop()
//            self.player = nil
//        }
        self.curiosityPopUpMenu = nil
        self.questionPopUpMenu = nil
        self.ground = nil
        self.roof = nil
        self.labels = nil
        self.background = nil
    }
    
    // MARK - Physics Delegate
    func didBeginContact(contact: SKPhysicsContact) {
        var bodyA = contact.bodyA
        var bodyB = contact.bodyB
        
        if( ( bodyB.categoryBitMask & HERO_CATEGORY  != 0 ) && ( bodyA.categoryBitMask & GROUND_CATEGORY != 0 ) ) {
            if( bodyB.node == nil ) {
              //  println("physics body is not connected to a node")
                
            }else{
                var hero = bodyB.node as! Hero
                hero.isHittingTheGround = true
            }
        }else if( ( bodyA.categoryBitMask & HERO_CATEGORY  != 0 ) && ( bodyB.categoryBitMask & GROUND_CATEGORY != 0 ) ) {
            if( bodyA.node == nil ) {
             //   println("physics body is not connected to a node")
                
            }else{
                var hero = bodyA.node as! Hero
                hero.isHittingTheGround = true
            }
        }
        
        if( ( bodyA.categoryBitMask & HERO_CATEGORY != 0 ) && ( bodyB.categoryBitMask & OBSTACLE_CATEGORY != 0 ) ) {
            
            if( bodyA.node == nil || bodyB.node == nil ) {
               // println("physics body is not connected to a node")
            }else {
                self.heroDidTouchObject(bodyA.node as! Hero, object: bodyB.node as! SKSpriteNode)
            }
        }else if( ( bodyA.categoryBitMask & HERO_CATEGORY != 0 ) && ( bodyB.categoryBitMask & PORTAL_CATEGORY != 0 ) ) {
            if( bodyA.node == nil || bodyB.node == nil ) {
               // println("physics body is not connected to a node")
            }else {
                //DispatchQueue.main.async {
                    self.goToNextLevel()
                //}
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        var bodyA = contact.bodyA
        var bodyB = contact.bodyB
        
        if( ( bodyB.categoryBitMask & HERO_CATEGORY  != 0 ) && ( bodyA.categoryBitMask & GROUND_CATEGORY != 0 ) ) {
            if( bodyB.node == nil ) {
               // println("physics body is not connected to a node")
                
            }else{
                var hero = bodyB.node as! Hero
                hero.isHittingTheGround = false
            }
        }else if( ( bodyA.categoryBitMask & HERO_CATEGORY  != 0 ) && ( bodyB.categoryBitMask & GROUND_CATEGORY != 0 ) ) {
            if( bodyA.node == nil ) {
              //  println("physics body is not connected to a node")
                
            }else{
                var hero = bodyA.node as! Hero
                hero.isHittingTheGround = false
            }
        }

    }
}

// Useful extensions
extension SKSpriteNode {

    func createPhysicsBodyForSelfWithCategory(_ category: UInt32, contactCategory: UInt32, collisionCategory: UInt32, squaredBody: Bool = false) {
        
        if let body = self.physicsBody {
            body.categoryBitMask = category
            body.contactTestBitMask = contactCategory
            body.collisionBitMask = collisionCategory
        } else {
            var body: SKPhysicsBody
            //if( squaredBody ) {
                body = SKPhysicsBody(rectangleOf: self.frame.size/*, center: CGPoint(x: 0, y: -self.frame.size.height*0.0)*/)
            //}else {
            //    body = SKPhysicsBody(texture: self.texture, size: self.frame.size)
            //}
            body.categoryBitMask = category
            body.contactTestBitMask = contactCategory
            body.collisionBitMask = collisionCategory
            body.isDynamic = true
            body.allowsRotation = false
            self.physicsBody = body
        }
    }
}
extension SKShapeNode{
    
    func createPhysicsBodyForSelfWithCategory(_ category: UInt32, contactCategory: UInt32, collisionCategory: UInt32, dynamic: Bool = false, affectedByGravity: Bool = true) {
    if let pB = self.physicsBody{
        var newBody =  SKPhysicsBody(polygonFrom: self.path!)
        newBody.isDynamic = dynamic
        newBody.categoryBitMask = category
        newBody.collisionBitMask = collisionCategory
        newBody.contactTestBitMask = contactCategory
        newBody.velocity = pB.velocity
        newBody.affectedByGravity = affectedByGravity
        self.physicsBody = newBody
    }else{
        self.physicsBody = SKPhysicsBody(polygonFrom: self.path!)
            if let pB = self.physicsBody {
                pB.isDynamic = dynamic
                pB.categoryBitMask = category
                pB.collisionBitMask = collisionCategory
                pB.contactTestBitMask = contactCategory
                pB.affectedByGravity = affectedByGravity
            }
    }
    }
}
