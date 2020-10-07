//
//  SeqManager.swift
//  SparkPerso
//
//  Created by Nael Messaoudene on 25/09/2020.
//  Copyright © 2020 AlbanPerli. All rights reserved.
//

import Foundation
import DJISDK

class SeqManager {
    
    static let instance = SeqManager()
    let spark = DJISDKManager.product() as? DJIAircraft
    
    struct Move {
        var duration:Double
        var speed:Float
        var axe:Character
    }
    
    var moves = [
        Move(duration: 3.0, speed: 0.3, axe: "Z"),
        Move(duration: 2.0, speed: 0.3, axe: "X"),
        Move(duration: 2.0, speed: -0.3, axe: "X"),
        Move(duration: 3.0, speed: -0.3, axe: "Z")
    ]
    
    func move() {
        
        if self.moves.count > 0 {
            print("Movement \(self.moves.first)")

            if let currentMove = self.moves.first {
                self.applyMovement(move: currentMove)
                DispatchQueue.main.asyncAfter(deadline: .now() + currentMove.duration) {
                    print("movement finished")
                    self.stop()
                    if self.moves.count > 0 {
                        self.moves.remove(at: 0)
                        print(self.moves)
                        
                        self.move()
                    }
                    
                }
            }
    
            
        } else {
            
        }
        
    }
    
    func clear() {
        self.moves.removeAll()
    }
    
    func applyMovement(move:Move) {
        self.stop()
        print("Movement \(move.axe)", "Speed \(move.speed)","Duration \(move.duration)")
        if let mySpark = spark {
            switch move.axe {
            case "X":
                mySpark.mobileRemoteController?.rightStickHorizontal = move.speed
            case "Y":
                mySpark.mobileRemoteController?.leftStickVertical = move.speed
            case "Z":
                mySpark.mobileRemoteController?.rightStickVertical = move.speed
            default:
                self.stop()
            }
        }
    }
    
    func stop () {
        print("stop")
        if let mySpark = spark {
            mySpark.mobileRemoteController?.leftStickVertical = 0.0
            mySpark.mobileRemoteController?.leftStickHorizontal = 0.0
            mySpark.mobileRemoteController?.rightStickHorizontal = 0.0
            mySpark.mobileRemoteController?.rightStickVertical = 0.0
        }
    }
}
