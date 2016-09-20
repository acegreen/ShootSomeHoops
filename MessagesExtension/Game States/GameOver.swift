//
//  GameOver.swift
//  Shoot Some Hoops
//
//  Created by Ace Green on 9/16/16.
//  Copyright © 2016 Ace Green. All rights reserved.
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
        
        // play game over sound
        scene.run(scene.gameOverSound)
        
        // display game over message
        let gameMessage = SKSpriteNode(imageNamed: "GameOver")
        gameMessage.name = GameScene.SpriteType.GameMessageName
        gameMessage.position = CGPoint(x: self.scene.frame.midX, y: self.scene.frame.midY)
        gameMessage.zPosition = 4
        gameMessage.setScale(0.0)
        self.scene.addChild(gameMessage)
        
        let scale = SKAction.scale(to: 1.0, duration: 0.25)
        scene.childNode(withName: GameScene.SpriteType.GameMessageName)!.run(scale)
    }
    
//    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
//        return stateClass is WaitingForTap.Type
//    }
}
