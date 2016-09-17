//
//  Basket.swift
//  Shoot Some Hoops
//
//  Created by Ace Green on 9/17/16.
//  Copyright © 2016 Ace Green. All rights reserved.
//

import Foundation
import SpriteKit

class Basket: SKNode {
    
    let rad:CGFloat = 200
    let h:CGFloat = 10
    var ring:SKShapeNode?
    
    override init() {
        super.init()
        initRing()
        initScoreSensor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var sensor:SKNode?
    func initScoreSensor() {
        sensor = SKNode()
        let phy = SKPhysicsBody(circleOfRadius: 3*h, center: CGPoint(x: rad/2, y: -rad/2))
        phy.affectedByGravity = false
        phy.isDynamic = false
        phy.collisionBitMask = GameScene.CategoryBitMask.NoneCategory
        phy.contactTestBitMask = GameScene.CategoryBitMask.BallCategory
        phy.categoryBitMask = GameScene.CategoryBitMask.SensorCategory
        sensor!.physicsBody = phy
        addChild(sensor!)
    }
    
    func initRing() {
        ring = SKShapeNode(rect: CGRect(x: 0, y: 0, width: rad, height: 2*h))
        ring!.fillColor = UIColor.red
        let l = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 2*h), to: CGPoint(x: 3*h, y: 2*h))
        let r = SKPhysicsBody(edgeFrom: CGPoint(x: rad-3*h, y: 2*h), to: CGPoint(x: rad, y: 2*h))
        ring!.physicsBody = SKPhysicsBody(bodies: [l,r])
        ring!.physicsBody?.affectedByGravity = false
        ring!.physicsBody?.isDynamic = false
        ringEnabled = false
        addChild(ring!)
    }
    var ringEnabled:Bool {
        set {
            ring?.physicsBody?.collisionBitMask = newValue ? GameScene.CategoryBitMask.BallCategory : GameScene.CategoryBitMask.NoneCategory
            ring?.physicsBody?.categoryBitMask = newValue ? GameScene.CategoryBitMask.BasketCategory : GameScene.CategoryBitMask.NoneCategory
        }
        get {
            return ring?.physicsBody?.collisionBitMask == GameScene.CategoryBitMask.BallCategory
        }
    }
}
