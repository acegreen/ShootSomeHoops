//
//  GameScene.swift
//  Bamboo Breakout
//
//  Created by Michael Briscoe on 4/8/16.
//  Copyright (c) 2016 Razeware LLC. All rights reserved.
//

import SpriteKit
import GameplayKit
import Messages

protocol GameSceneDelegate {
    func gameVCWillTransition(to presentationStyle: MSMessagesAppPresentationStyle)
    func gameVCWillTansition(to size: CGSize)
}

class GameScene: SKScene, SKPhysicsContactDelegate, GameSceneDelegate {

    struct SpriteType {
        static let BallCategoryName = "ball"
        static let GameMessageName = "gameMessage"
    }
    
    struct CategoryBitMask {
        static let NoneCategory   : UInt32 = 0x1 << 0
        static let BallCategory   : UInt32 = 0x1 << 1
        static let BasketCategory : UInt32 = 0x1 << 2
        static let SensorCategory : UInt32 = 0x1 << 3
    }
    
    let whistleSound = SKAction.playSoundFileNamed("whistle", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("game-over", waitForCompletion: false)
    let kickSound = SKAction.playSoundFileNamed("kick", waitForCompletion: false)
    
    var gameDelegate: GameDelegate?
    
    var ball: SKSpriteNode!
    var basket: Basket!
    
    var game = Game()
    
    var dragStart: CGPoint?
    var gameOver : Bool = false
    
    lazy var gameState: GKStateMachine = GKStateMachine(states: [
        WaitingForTap(scene: self),
        Playing(scene: self),
        GameOver(scene: self)])
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Setup environment
        self.ball = childNode(withName: SpriteType.BallCategoryName) as! SKSpriteNode
        centerBall()
        addChild(newBasket())
        
        // Add CategoryBitMask
        ball.physicsBody!.categoryBitMask = CategoryBitMask.BallCategory
        
        // Add contactTestBitMask
        ball.physicsBody!.contactTestBitMask = CategoryBitMask.BallCategory
        
        // Assign contactDelegate
        physicsWorld.contactDelegate = self
        
        gameState.enter(WaitingForTap.self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        //let touchLocationBall = touch!.location(in: self.ball)
        
        switch gameState.currentState {
        case is WaitingForTap:
            
            gameDelegate?.expandView()
            gameDelegate?.updateScore(game: self.game)
            gameState.enter(Playing.self)
            
        case is Playing:
        
            if let body = physicsWorld.body(at: touchLocation) {
                if body.node! == self.ball {
                    
                    print("Began touch on ball")
                    
                    guard dragStart == nil else { return }
                    dragStart = touches.first?.location(in: self)
                }
            }
            
        case is GameOver:
            
            if let newScene = GameScene(fileNamed:"GameScene") {

                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                self.view?.presentScene(newScene, transition: reveal)
                
                gameDelegate?.resetScene(scene: newScene)
            }
            
        default:
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let start = dragStart else { return }
        let end = touches.first!.location(in: self)
        shoot(from: start, to: end)
        dragStart = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if ballAboveRing() {
            basket.ringEnabled = true
            ballBeforeRing()
        }
    
        if self.frame.intersection(ball.frame).isNull && self.ball.position.y < 0 {
            
            if !self.gameOver {
                gameState.enter(GameOver.self)
                gameOver = true
                gameDelegate?.gameOver(game: self.game)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // 2
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 3
        if firstBody.categoryBitMask == CategoryBitMask.BallCategory && secondBody.categoryBitMask == CategoryBitMask.BallCategory {
        }
    }
    
    // GameSceneDelegate
    func gameVCWillTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        
        switch presentationStyle {
        case .compact:
            
            if self.gameOver {
                if let newScene = GameScene(fileNamed:"GameScene") {
                    self.view?.presentScene(newScene)
                    gameDelegate?.resetScene(scene: newScene)
                }
            } else {
                gameState.enter(WaitingForTap.self)
            }
            
        case .expanded:
            
            print("expannded")
        }
    }
    
    func gameVCWillTansition(to size: CGSize) {
        print("VC Size", size)
    }
    
    func shoot(from:CGPoint, to:CGPoint){
        let dx = (to.x-from.x)/2.5
        let dy = to.y-from.y
        let norm = sqrt(pow(dx, 2) + pow(dy, 2))
        let base:CGFloat = 2000
        ball.physicsBody?.affectedByGravity = true
        let impulse = CGVector(dx: base * (dx/norm), dy: base * (dy/norm))
        ball.physicsBody?.applyImpulse(impulse)
        let scale:CGFloat = 0.5
        let scaleDuration:TimeInterval = 1.1
        run(SKAction.scale(by: scale, duration: scaleDuration))
    }
    
    func ballAboveRing() -> Bool {
        return ball.position.y > basket.position.y
    }
    
    func ballBeforeRing() {
        ball.zPosition = 1
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        guard basket!.ringEnabled else { return }
        
        // Increment score
        self.game.currentScore += 1
        gameDelegate?.updateScore(game: self.game)
    }
    
    func newBasket() -> Basket {
        let basket = Basket()
        self.basket = basket
        basket.position = CGPoint(x: frame.midX - basket.rad/2, y: self.view!.frame.height * (2/3))
        return basket
    }
    
    // Helper functions
    func centerBall() {
        self.ball.position = CGPoint(x: self.view!.frame.midX, y: (self.ball.size.height / 2) + 50)
    }
}
