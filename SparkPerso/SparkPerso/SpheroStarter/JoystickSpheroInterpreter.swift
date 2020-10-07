//
//  JoystickSpheroInterpreter.swift
//  SparkPerso
//
//  Created by Florian on 06/10/2020.
//  Copyright © 2020 AlbanPerli. All rights reserved.
//

import Foundation

class JoystickSpheroInterpreter {
    
    enum Steps: Double {
        case none = 0.0
        case low = 0.40
        case medium = 0.60
        case high = 0.80
    }
    
    
    static func convert (x: Double, y: Double, heading: Double) -> (currentHeading: Double, currentSpeed: Double, reverse: Bool) {
        
        let xIsEmpty: Bool = x < Steps.low.rawValue && x > -Steps.low.rawValue
        let yIsEmpty: Bool = y < Steps.low.rawValue && y > -Steps.low.rawValue
        var currentHeading: Double = 0.0
        var currentSpeed: Double = 0.0
        var reverse: Bool = false
        
        let maxValue = [abs(x), abs(y)].max()
        
        if (!xIsEmpty && yIsEmpty) {
            if x > Steps.low.rawValue {
                // gauche
                print("gauche")
                currentHeading = heading + 270
            } else {
                // droite
                currentHeading = heading + 90.0
            }
        } else if (!yIsEmpty && xIsEmpty) {
            if y > Steps.low.rawValue {
//                reverse = true
                currentHeading = heading + 180
            } else {
                currentHeading = 0
            }
        } else if (!xIsEmpty && !yIsEmpty) {
            
            if y > Steps.low.rawValue {
                if x > Steps.low.rawValue {
                    // gauche
                    currentHeading = heading + 225
                } else {
                    // droite
                    currentHeading = heading + 135.0
                }
            } else {
                if x > Steps.low.rawValue {
                    // gauche
                    currentHeading = heading + 315
                } else {
                    // droite
                    currentHeading = heading + 45.0
                }
            }            
        }
        
        currentSpeed = handleSpeed(maxValue: maxValue!)
        
        return (currentHeading, currentSpeed, reverse)
    }
    

    static func handleSpeed (maxValue: Double) -> Double {
        let COEFF = 120.0
        if maxValue > Steps.low.rawValue && maxValue < Steps.medium.rawValue {
            return Steps.low.rawValue * COEFF
        } else if maxValue > Steps.medium.rawValue && maxValue < Steps.high.rawValue {
            return Steps.medium.rawValue * COEFF
        } else if maxValue > Steps.high.rawValue {
            return Steps.high.rawValue * COEFF
        } else {
            return 0.0
        }
    }
}
