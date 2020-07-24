//
//  MenuScene.swift
//  Hidden Golf
//
//  Created by Scott Schnieders on 7/23/20.
//  Copyright © 2020 Scott Schnieders. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    let middle = CGPoint(x: 667, y: 375)
    
    var playLabel: SKLabelNode!
    var infoLabel: SKLabelNode!
    var button: SKSpriteNode!

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.frame.size
        background.position = middle
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        playLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        playLabel.text = "Hidden Golf"
        playLabel.fontColor = UIColor(ciColor: .black)
        playLabel.fontSize = 85
        playLabel.horizontalAlignmentMode = .center
        playLabel.position = CGPoint(x: 667, y: 440)
        addChild(playLabel)
        
        infoLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        infoLabel.text = "Tilt Your Phone to Find the Hidden Hole"
        infoLabel.fontColor = UIColor(ciColor: .black)
        infoLabel.fontSize = 40
        infoLabel.horizontalAlignmentMode = .center
        infoLabel.position = CGPoint(x: 667, y: 200)
        addChild(infoLabel)
        
        button = SKSpriteNode(imageNamed: "play")
        button.position = CGPoint(x: 667, y: 320)
        button.name = "button"
        addChild(button)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return}
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        if objects.contains(button) {
            if let view = view {
                let transition:SKTransition = SKTransition.fade(withDuration: 1)
                let scene:SKScene = GameScene(size: self.size)
                view.presentScene(scene, transition: transition)
            }
        }
    }
}
