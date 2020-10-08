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
    
    var pos = (x: 0, y: 0)
    var isAllowToMove = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if SharedToyBox.instance.bolts.count > 2 {
//
//        }
        
        SharedToyBox.instance.bolts[0].setFrontLed(color: .green)
        SharedToyBox.instance.bolts[0].sensorControl.enable(sensors: SensorMask.init(arrayLiteral: .accelerometer,.gyro))
        SharedToyBox.instance.bolts[0].sensorControl.interval = 1
        SharedToyBox.instance.bolts[0].setStabilization(state: SetStabilization.State.off)
        SharedToyBox.instance.bolts[0].sensorControl.onDataReady = { data in
            DispatchQueue.main.async { [self] in
                if let accelerometer = data.accelerometer {
                    if let acceleration = accelerometer.filteredAcceleration {
                        if let x = acceleration.x, let y = acceleration.y, let z = acceleration.z {
                            let datasConverted = JoystickSparkInterpreter.convert(x: x, y: y, currentPos: self.pos)
                            self.updatePosition(newX: datasConverted.newX, newY: datasConverted.newY, action: datasConverted.action)
//                            print(datasConverted)
                        }
                    }
                }
            }
        }
    }
    
    func updatePosition (newX: Int, newY: Int, action: Movement.Direction) {
        if (isAllowToMove) {
            if newY == 2 || newX == 2 || newY == -2 || newX == -2 {
                print("return")
                return
            }
            
            if pos != (newX, newY) {
                pos = (newX, newY)
                print("pos \(pos)")
                isAllowToMove = false
                
                if let mySpark = spark {
                    switch action {
                        case Movement.Direction.front:
                            mySpark.mobileRemoteController?.rightStickVertical = 0.2
                        case Movement.Direction.back:
                            mySpark.mobileRemoteController?.rightStickVertical = -0.2
                        case Movement.Direction.left:
                            mySpark.mobileRemoteController?.rightStickHorizontal = -0.2
                        case Movement.Direction.right:
                            mySpark.mobileRemoteController?.rightStickHorizontal = 0.2
                        case Movement.Direction.nothing:
                            self.stop()
                        default:
                            return
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.stop()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isAllowToMove = true
                }
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
    
    @IBAction func startSequence(_ sender: UIButton) {
        SeqManager.instance.move()
    }
    
    @IBAction func left(_ sender: UIButton) {
        print("left")
//        updatePosition(newX: pos.x-1, newY: pos.y, action: Movement.Direction.left)
//        if let mySpark = DJISDKManager.product() as? DJIAircraft {
//            mySpark.mobileRemoteController?.rightStickHorizontal = -0.5
//        }
    }
    @IBAction func right(_ sender: UIButton) {
        print("right")
//        updatePosition(newX: pos.x+1, newY: pos.y, action: Movement.Direction.right)
//        if let mySpark = DJISDKManager.product() as? DJIAircraft {
//            mySpark.mobileRemoteController?.rightStickHorizontal = 0.5
//        }
        
    }
    @IBAction func backward(_ sender: UIButton) {
        print("backward")
//        sendCommand(Movement(value: -commonValue, type: .backward))
//        updatePosition(newX: pos.x, newY: pos.y-1, action: Movement.Direction.back)
//        if let mySpark = DJISDKManager.product() as? DJIAircraft {
//            mySpark.mobileRemoteController?.rightStickVertical = -0.5
//        }
    }
    
    @IBAction func forward(_ sender: UIButton) {
//        print("forward")
//        updatePosition(newX: pos.x, newY: pos.y+1, action: Movement.Direction.front)
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
        
//        if let mySpark = DJISDKManager.product() as? DJIAircraft {
//            mySpark.mobileRemoteController?.leftStickVertical = -0.5
//        }
    }
    
    
    @IBAction func up(_ sender: UIButton) {
        print("up ")
//        sendCommand(Movement(value: commonValue, type: .up))
        
//        if let mySpark = DJISDKManager.product() as? DJIAircraft {
//            mySpark.mobileRemoteController?.leftStickVertical = 0.5
//        }

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
