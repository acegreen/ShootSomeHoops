//
//  GameOver.swift
//  BreakoutSpriteKitTutorial
//
//  Created by Michael Briscoe on 1/16/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameOver: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Game Over State")
        
        let gameOver = self.scene.childNode(withName: GameScene.SpriteType.GameMessageName) as! SKSpriteNode
        let textureName = "GameOver"
        let texture = SKTexture(imageNamed: textureName)
        let actionSequence = SKAction.sequence([SKAction.setTexture(texture),
                                                SKAction.scale(to: 1.0, duration: 0.25)])
        
        gameOver.run(actionSequence)
        scene.run(scene.gameOverSound)
    }
    
//    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
//        return stateClass is WaitingForTap.Type
//    }
}
