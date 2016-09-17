//
//  Game.swift
//  Keep Ups
//
//  Created by Ace Green on 9/16/16.
//  Copyright © 2016 Ace Green. All rights reserved.
//

import Foundation

public class Game {
    
    var currentScore: Int = 0 {
        didSet {
            if currentScore > highScore {
                highScore = currentScore
            }
        }
    }
    
    var highScore: Int = 0
}
