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
    
    let rad:CGFloat = 175
    let h:CGFloat = 10
    var ring: SKShapeNode!
    var sensor:SKNode!
    
    override init() {
        super.init()
        initRing()
        initScoreSensor()
        isEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initScoreSensor() {
        sensor = SKNode()
        let phy = SKPhysicsBody(edgeFrom: CGPoint(x: (2*h), y: -50), to: CGPoint(x: rad - (2*h), y: -50))
        phy.affectedByGravity = false
        phy.isDynamic = false
        phy.collisionBitMask = GameScene.CategoryBitMask.NoneCategory
        phy.categoryBitMask = GameScene.CategoryBitMask.SensorCategory
        sensor!.physicsBody = phy
        addChild(sensor!)
    }
    
    func initRing() {
        ring = SKShapeNode()
        ring.path = CGPath(roundedRect: CGRect(x: 0, y: 0, width: rad, height: h), cornerWidth: 5, cornerHeight: 5, transform: nil)
        ring.fillColor = UIColor.red
        let l = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: h), to: CGPoint(x: 2*h, y: h))
        let r = SKPhysicsBody(edgeFrom: CGPoint(x: rad-2*h, y: h), to: CGPoint(x: rad, y: h))
        ring.physicsBody = SKPhysicsBody(bodies: [l,r])
        ring.physicsBody?.affectedByGravity = false
        ring.physicsBody?.isDynamic = false
        addChild(ring!)
    }
    var isEnabled: Bool {
        set {
            sensor.physicsBody?.contactTestBitMask = newValue ? GameScene.CategoryBitMask.BallCategory : GameScene.CategoryBitMask.NoneCategory
            ring.physicsBody?.collisionBitMask = newValue ? GameScene.CategoryBitMask.BallCategory : GameScene.CategoryBitMask.NoneCategory
            ring.physicsBody?.categoryBitMask = newValue ? GameScene.CategoryBitMask.BasketCategory : GameScene.CategoryBitMask.NoneCategory
        }
        get {
            return ring.physicsBody?.collisionBitMask == GameScene.CategoryBitMask.BallCategory
        }
    }
}
