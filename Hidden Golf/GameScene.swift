//
//  GameScene.swift
//  Hidden Golf
//
//  Created by Scott Schnieders on 7/22/20.
//  Copyright © 2020 Scott Schnieders. All rights reserved.
//

import CoreMotion
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var motionManager: CMMotionManager!
    var winPoint: CGPoint!
    let middle = CGPoint(x: 667, y: 375)
    var yMotion:Double = 50
    var xMotion:Double = -50
    
    var won: Bool = false
    var level = 1
    
    var winLabel: SKLabelNode!
    var levelLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    var backButton: SKSpriteNode!
    var forButton: SKSpriteNode!
    
    var levelTimerValue: Int = 200 {
        didSet {
            timeLabel.text = "Time left: \(levelTimerValue)"
        }
    }

    override func didMove(to view: SKView) {
        setupScene()
    }
    
    func setupScene() {
        
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
            yMotion = -50
            xMotion = 50
        }
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            yMotion = 50
            xMotion = -50
        }
        physicsWorld.gravity = .zero
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.frame.size
        background.position = middle
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        let golfBall = SKSpriteNode(imageNamed: "golfBall")
        golfBall.size = CGSize(width: 150 - (20*level), height: 150 - (20*level))
        golfBall.position = middle
        golfBall.zPosition = 2
        golfBall.physicsBody = SKPhysicsBody(circleOfRadius: golfBall.size.width / 2)
        golfBall.physicsBody?.allowsRotation = false
        golfBall.physicsBody?.linearDamping = 0.5
        golfBall.physicsBody?.contactTestBitMask = golfBall.physicsBody?.collisionBitMask ?? 0
        golfBall.name = "ball"
        addChild(golfBall)
        
        makeTimer(ball: golfBall)
        
        levelLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        levelLabel.text = "Level: \(level)"
        levelLabel.fontSize = 40
        levelLabel.fontColor = UIColor(ciColor: .black)
        levelLabel.horizontalAlignmentMode = .right
        levelLabel.position = CGPoint(x: 1234, y: 700)
        addChild(levelLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeWall(at: CGPoint(x: 0, y: 375), true)
        makeWall(at: CGPoint(x: 1334, y: 375), true)
        makeWall(at: CGPoint(x: 667, y: 750), false)
        makeWall(at: CGPoint(x: 667, y: 0), false)
        
        makeHole(at: CGPoint(x: Int.random(in: 1...1333), y: Int.random(in: 1...749)))
        
    }
    
    func resetScene() {
        removeAllActions()
        removeAllChildren()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * yMotion, dy: accelerometerData.acceleration.x * xMotion)
        }
    }
    func makeWall(at position:CGPoint,_ side:Bool) {
        let wall = SKSpriteNode()
        if side {
            wall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 0.5, height: 1500))
        } else {
            wall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1500, height: 0.5))
        }
        wall.position = position
        wall.physicsBody?.isDynamic = false
        addChild(wall)
    }
    
    func makeHole(at position:CGPoint) {
        winPoint = position
        
        let hole = SKSpriteNode()
        hole.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        hole.position = position
        hole.physicsBody?.isDynamic = false
        hole.name = "hole"
        addChild(hole)
    }
    
    //Finds the hole
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "hole" {
            if action(forKey: "countdown") != nil {removeAction(forKey: "countdown")}
            
            ball.physicsBody?.isDynamic = false
            ball.physicsBody?.contactTestBitMask = 0
            let move = SKAction.move(to: winPoint, duration: 0.4)
            let scale = SKAction.scale(to: 0.5, duration: 0.65)
            let actions = [move, scale]
            let sequence = SKAction.sequence(actions)
            ball.run(sequence)
            
            emmiter(at: CGPoint(x: 1334, y: 750))
            emmiter(at: CGPoint(x: 0, y: 750))
            
            showHole(at: winPoint)
            makeLabel("Hole in One!", at: middle)
            //add level label
            
            showButtons(didWin: true)
        }
    }
    
    func showButtons(didWin:Bool) {
        if didWin {
            forButton = SKSpriteNode(imageNamed: "forButton")
            forButton.position = CGPoint(x: 1184, y: 100)
            forButton.zPosition = 3
            addChild(forButton)
        }
        backButton = SKSpriteNode(imageNamed: "backButton")
        backButton.position = CGPoint(x: 150, y: 100)
        backButton.zPosition = 3
        addChild(backButton)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
    
    func showHole(at position: CGPoint) {
        let whiteHole = SKSpriteNode(imageNamed: "whiteHole")
        whiteHole.size = CGSize(width: 230, height: 230)
        whiteHole.position = position
        whiteHole.zPosition=0
        whiteHole.physicsBody = SKPhysicsBody(circleOfRadius: 20, center: position)
        whiteHole.physicsBody?.isDynamic = false
        whiteHole.physicsBody?.collisionBitMask = 0
        addChild(whiteHole)
        
        let blackHole = SKSpriteNode(imageNamed: "blackHole")
        blackHole.size = CGSize(width: 210, height: 210)
        blackHole.position = position
        blackHole.zPosition=1
        blackHole.physicsBody = SKPhysicsBody(circleOfRadius: 20, center: position)
        blackHole.physicsBody?.isDynamic = false
        blackHole.physicsBody?.collisionBitMask = 0
        addChild(blackHole)
    }
    
    func emmiter(at pos:CGPoint) {
        if let sparkler = SKEmitterNode(fileNamed: "sparkler") {
            sparkler.position = pos
            addChild(sparkler)
        }
    }
    
    func makeLabel(_ text: String, at pos: CGPoint) {
        winLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        winLabel.numberOfLines = 2
        winLabel.text = text
        winLabel.fontColor = UIColor(ciColor: .black)
        winLabel.fontSize = 72
        winLabel.horizontalAlignmentMode = .center
        winLabel.position = pos
        winLabel.zPosition = 3
        addChild(winLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return}
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        if objects.contains(backButton) {
            if let view = view {
                let transition:SKTransition = SKTransition.fade(withDuration: 1)
                let scene:SKScene = MenuScene(size: self.size)
                view.presentScene(scene, transition: transition)
            }
        } else if objects.contains(forButton) {
            resetScene()
            level += 1
            levelTimerValue = 200
            setupScene()
        }
    }
    
    func makeTimer(ball: SKNode) {
        
        timeLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        timeLabel.position = CGPoint(x: 100, y: 700)
        timeLabel.text = ""
        timeLabel.zPosition = 3
        timeLabel.fontColor = UIColor(ciColor: .black)
        timeLabel.fontSize = 40
        timeLabel.horizontalAlignmentMode = .left
        addChild(timeLabel)
        
        levelTimerValue -= (20 * level)
        
        let wait = SKAction.wait(forDuration: 0.5) //change countdown speed here
        let block = SKAction.run({
            [unowned self] in

            if self.levelTimerValue > 0{
                self.levelTimerValue -= 1
            }else{
                self.removeAction(forKey: "countdown")
                ball.physicsBody?.isDynamic = false
                ball.physicsBody?.contactTestBitMask = 0
                self.showButtons(didWin: false)
                self.makeLabel("You Lose!", at: self.middle)
                //times up
            }
        })
        let sequence = SKAction.sequence([wait,block])

        run(SKAction.repeatForever(sequence), withKey: "countdown")
    }

}
