//
//  WaitingForTap.swift
//  BreakoutSpriteKitTutorial
//
//  Created by Michael Briscoe on 1/16/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class WaitingForTap: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        
        print("Waiting For Tap State")
        
        // Setup game state
        let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
        gameMessage.name = GameScene.SpriteType.GameMessageName
        gameMessage.position = CGPoint(x: self.scene.frame.midX, y: self.scene.frame.midY)
        gameMessage.zPosition = 4
        gameMessage.setScale(0.0)
        self.scene.addChild(gameMessage)
        
        let scale = SKAction.scale(to: 1.0, duration: 0.25)
        scene.childNode(withName: GameScene.SpriteType.GameMessageName)!.run(scale)
    }
    
    override func willExit(to nextState: GKState) {
        if nextState is Playing {
            let scale = SKAction.scale(to: 0, duration: 0.4)
            scene.childNode(withName: GameScene.SpriteType.GameMessageName)!.run(scale)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is Playing.Type
    }
}
