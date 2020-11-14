//
//  JoystickSparkInterpreter.swift
//  SparkPerso
//
//  Created by Florian on 06/10/2020.
//  Copyright © 2020 AlbanPerli. All rights reserved.
//

import Foundation

class JoystickSparkInterpreter {
    
    enum Steps: Double {
        case none = 0.0
        case low = 0.40
        case medium = 0.60
        case high = 0.80
    }
    
    static func convert (x: Double, y: Double, currentPos: (x: Int, y: Int)) -> (newX: Int, newY: Int, action: Movement.Direction) {
        
        let xIsEmpty: Bool = x < Steps.low.rawValue && x > -Steps.low.rawValue
        let yIsEmpty: Bool = y < Steps.low.rawValue && y > -Steps.low.rawValue
        var newX = 0
        var newY = 0
        var action = Movement.Direction.nothing
        
        if (!xIsEmpty && yIsEmpty) {
            if x > Steps.low.rawValue {
                newX = currentPos.x - 1
                newY = currentPos.y
                action = Movement.Direction.left
            } else {
                newX = currentPos.x + 1
                newY = currentPos.y
                action = Movement.Direction.right
            }
        } else if (!yIsEmpty && xIsEmpty) {
            if y > Steps.low.rawValue {
                newX = currentPos.x
                newY = currentPos.y - 1
                action = Movement.Direction.back
            } else {
                newX = currentPos.x
                newY = currentPos.y + 1
                action = Movement.Direction.front
            }
        } else {
            newY = currentPos.y
            newX = currentPos.x
            action = Movement.Direction.nothing
        }
        
        return (newX, newY, action)
    }
}
