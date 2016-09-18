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
        static let BackboardCategoryName = "backboard"
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
    let swishSound = SKAction.playSoundFileNamed("swish", waitForCompletion: false)
    
    var gameDelegate: GameDelegate?
    
    var ball: SKSpriteNode!
    var backboard: SKSpriteNode!
    var basket: Basket!
    
    var game = Game()
    
    var dragStart: CGPoint?
    var gameOver : Bool = false
    var didScore: Bool = false
    
    lazy var gameState: GKStateMachine = GKStateMachine(states: [
        Playing(scene: self),
        GameOver(scene: self)])
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Setup environment
        self.ball = childNode(withName: SpriteType.BallCategoryName) as! SKSpriteNode
        self.backboard = childNode(withName: SpriteType.BackboardCategoryName) as! SKSpriteNode
        self.backboard.position = CGPoint(x: self.view!.frame.midX, y: (self.view!.frame.height * (2/3)) + 20)
        centerBall()
        print(ball.zPosition)

        addChild(newBasket())
        
        // Add CategoryBitMask
        ball.physicsBody!.categoryBitMask = CategoryBitMask.BallCategory
        
        // Add collisionBitMask
        ball.physicsBody!.collisionBitMask = CategoryBitMask.BasketCategory
        
        // Assign contactDelegate
        physicsWorld.contactDelegate = self
        
        gameState.enter(Playing.self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        //let touchLocationBall = touch!.location(in: self.ball)
        
        switch gameState.currentState {
            
        case is Playing:
        
            gameDelegate?.updateScore(game: self.game)
            
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
            basket.isEnabled = true
            ballBeforeRing()
        }
    
        if self.frame.intersection(ball.frame).isNull && self.ball.position.y < 0 && !didScore {
            
            if !self.gameOver {
                gameState.enter(GameOver.self)
                gameOver = true
                gameDelegate?.gameOver(game: self.game)
            }
            
        } else if self.frame.intersection(ball.frame).isNull && self.ball.position.y < 0 && didScore {
            self.reset()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
//        // 1
//        var firstBody: SKPhysicsBody
//        var secondBody: SKPhysicsBody
//        
//        // 2
//        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
//            firstBody = contact.bodyA
//            secondBody = contact.bodyB
//        } else {
//            firstBody = contact.bodyB
//            secondBody = contact.bodyA
//        }
//        
//        // 3
//        if firstBody.categoryBitMask == CategoryBitMask.BallCategory && secondBody.categoryBitMask == CategoryBitMask.BallCategory {
//        }
    }
    
    // GameSceneDelegate
    func gameVCWillTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        
        switch presentationStyle {
        case .compact:
            
            print("compact")
            
        case .expanded:
            
            print("expannded")
        }
    }
    
    func gameVCWillTansition(to size: CGSize) {
        print("VC Size", size)
    }
    
    func shoot(from: CGPoint, to: CGPoint){
        let dx = to.x - from.x
        let dy = to.y - from.y
        let norm = sqrt(pow(dx, 2) + pow(dy, 2))
        let base: CGFloat = 1000
        ball.physicsBody?.affectedByGravity = true
        let impulse = CGVector(dx: base * (dx/norm), dy: base * (dy/norm))
        ball.physicsBody?.applyImpulse(impulse)
        let scale: CGFloat = 0.7
        let scaleDuration:TimeInterval = 1.0
        ball.run(SKAction.scale(by: scale, duration: scaleDuration))
    }
    
    func ballAboveRing() -> Bool {
        return ball.position.y > basket.position.y + 50
    }
    
    func ballBeforeRing() {
        ball.zPosition = 0
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
        guard basket.isEnabled else { return }
        
        didScore = true
        run(swishSound)
        
        // Increment score
        self.game.currentScore += 1
        gameDelegate?.updateScore(game: self.game)
    }
    
    // Helper functions
    
    func reset() {
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball.physicsBody?.angularVelocity = 0
        ball.zPosition = 1
        ball.zRotation = 0
        ball.xScale = 1
        ball.yScale = 1
        ball.position = ballPosition()
        basket.isEnabled = false
        didScore = false
    }
    
    func newBasket() -> Basket {
        let basket = Basket()
        self.basket = basket
        basket.position = CGPoint(x: frame.midX - basket.rad/2, y: self.backboard.frame.minY)
        return basket
    }
    
    func centerBall() {
        self.ball.position = CGPoint(x: self.view!.frame.midX, y: (self.ball.size.height / 2) + 50)
    }
    
    func ballPosition() -> CGPoint {
        return CGPoint(x: (CGFloat(arc4random_uniform(UInt32(frame.width)))), y: (self.ball.size.height / 2) + 50)
    }
}
