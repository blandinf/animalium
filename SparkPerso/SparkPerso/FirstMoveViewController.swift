//
//  FirstMoveViewController.swift
//  SparkPerso
//
//  Created by Nael Messaoudene on 23/09/2020.
//  Copyright © 2020 AlbanPerli. All rights reserved.
//

import UIKit
import DJISDK

class FirstMoveViewController: UIViewController {
    let spark = DJISDKManager.product() as? DJIAircraft
    
    enum MovementType {
        case forward,backward,left,right
    }
    
    var pos = (x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updatePosition (newX: Int, newY: Int, action: MovementType) {
        if newY == 2 || newX == 2 || newY == -2 || newX == -2 {
            return
        }
        pos = (newX, newY)
        
        if let mySpark = spark {
            switch action {
                case MovementType.forward:
                    mySpark.mobileRemoteController?.rightStickVertical = 0.2
                case MovementType.backward:
                    mySpark.mobileRemoteController?.rightStickVertical = -0.2
                case MovementType.left:
                    mySpark.mobileRemoteController?.rightStickHorizontal = 0.2
                case MovementType.right:
                    mySpark.mobileRemoteController?.rightStickHorizontal = -0.2
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.stop()
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
    
//    func applyMovement(move:Move) {
//        self.stop()
//        print("Movement \(move.axe)", "Speed \(move.speed)","Duration \(move.duration)")
//        if let mySpark = spark {
//            switch move.axe {
//            case "X":
//                mySpark.mobileRemoteController?.rightStickHorizontal = move.speed
//            case "Y":
//                mySpark.mobileRemoteController?.leftStickVertical = move.speed
//            case "Z":
//                mySpark.mobileRemoteController?.rightStickVertical = move.speed
//            default:
//                self.stop()
//            }
//        }
//    }
    
    @IBAction func startSequence(_ sender: UIButton) {
        SeqManager.instance.move()
    }
    
    @IBAction func left(_ sender: UIButton) {
        print("left")
        updatePosition(newX: pos.x-1, newY: pos.y, action: MovementType.left)
//        if let mySpark = DJISDKManager.product() as? DJIAircraft {
//            mySpark.mobileRemoteController?.rightStickHorizontal = -0.5
//        }
    }
    @IBAction func right(_ sender: UIButton) {
        print("right")
        updatePosition(newX: pos.x+1, newY: pos.y, action: MovementType.right)
//        if let mySpark = DJISDKManager.product() as? DJIAircraft {
//            mySpark.mobileRemoteController?.rightStickHorizontal = 0.5
//        }
        
    }
    @IBAction func backward(_ sender: UIButton) {
        print("backward")
//        sendCommand(Movement(value: -commonValue, type: .backward))
        updatePosition(newX: pos.x, newY: pos.y-1, action: MovementType.backward)
//        if let mySpark = DJISDKManager.product() as? DJIAircraft {
//            mySpark.mobileRemoteController?.rightStickVertical = -0.5
//        }
    }
    
    @IBAction func forward(_ sender: UIButton) {
//        print("forward")
        updatePosition(newX: pos.x, newY: pos.y+1, action: MovementType.forward)
//        if let mySpark = DJISDKManager.product() as? DJIAircraft {
//            mySpark.mobileRemoteController?.rightStickVertical = 0.5
//        }
//        let mov = Movement(value: commonValue, type: .forward)
//        sendCommand(mov)
//
    }
    
    @IBAction func down(_ sender: UIButton) {
        print("down ")
//        sendCommand(Movement(value: -commonValue, type: .down))
        
        if let mySpark = DJISDKManager.product() as? DJIAircraft {
            mySpark.mobileRemoteController?.leftStickVertical = -0.5
        }
    }
    
    
    @IBAction func up(_ sender: UIButton) {
        print("up ")
//        sendCommand(Movement(value: commonValue, type: .up))
        
        if let mySpark = DJISDKManager.product() as? DJIAircraft {
            mySpark.mobileRemoteController?.leftStickVertical = 0.5
        }

    }
    
    
    @IBAction func landing(_ sender: UIButton) {
        print("landing ")
        if let mySpark = DJISDKManager.product() as? DJIAircraft {
            if let flightController = mySpark.flightController {
                flightController.startLanding(completion: { (err) in
                    print(err.debugDescription)
                })
            }
        }
    }
    
    
    @IBAction func takeOff(_ sender: UIButton) {
        print("take off ")
        
        if let mySpark = DJISDKManager.product() as? DJIAircraft {
            if let flightController = mySpark.flightController {
                flightController.startTakeoff(completion: { (err) in
                    print(err.debugDescription)
                })
            }
        }
        
    }
    @IBAction func stop(_ sender: UIButton) {
        print("stop")
        SeqManager.instance.clear()
        if let mySpark = DJISDKManager.product() as? DJIAircraft {
            mySpark.mobileRemoteController?.leftStickVertical = 0.0
            mySpark.mobileRemoteController?.leftStickHorizontal = 0.0
            mySpark.mobileRemoteController?.rightStickHorizontal = 0.0
            mySpark.mobileRemoteController?.rightStickVertical = 0.0
        }
    }
    
    

    
//
//    func sendCommand(_ movement:Movement) {
//        if let mySpark = DJISDKManager.product() as? DJIAircraft {
//            switch movement.type {
//            case .forward,.backward:
//                mySpark.mobileRemoteController?.rightStickVertical = movement.value
//            case .left,.right:
//                mySpark.mobileRemoteController?.rightStickHorizontal = movement.value
//            case .up,.down:
//                mySpark.mobileRemoteController?.leftStickVertical = movement.value
//            }
//        }
//    }
    /*
    // MARK: - Navigation


     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
