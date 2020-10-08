//
//  Mouvement.swift
//  SparkPerso
//
//  Created by AL on 11/01/2019.
//  Copyright © 2019 AlbanPerli. All rights reserved.
//

import UIKit

struct Movement {
    var direction:Direction
    var duration:CGFloat
    var speed:CGFloat
    
    enum Direction:String,CaseIterable {
        case front, back, up, down,left,right,topRight,topLeft,bottomRight,bottomLeft, nothing
        
        func value() -> CGPoint {
            switch self {
                case .up: return CGPoint(x: 0, y: 1)
                case .down: return CGPoint(x: 0, y: -1)
                case .left: return CGPoint(x: -1, y: 0)
                case .right: return CGPoint(x: 1, y: 0)
                case .topRight: return CGPoint(x: 1, y: 1)
                case .topLeft: return CGPoint(x: -1, y: 1)
                case .bottomRight: return CGPoint(x: 1, y: -1)
                case .bottomLeft: return CGPoint(x: -1, y: -1)
                case .nothing: return CGPoint()
                default: return CGPoint()
            }
        }
    }
    
    func description() -> String {
        return "\(direction.rawValue) during \(duration)s"
    }
    
    func rightStickVerticalValue() -> Float {
        return Float(direction.value().y*speed)
    }
    
    func rightStickHorizontalValue() -> Float {
        return Float(direction.value().x*speed)
    }
}

