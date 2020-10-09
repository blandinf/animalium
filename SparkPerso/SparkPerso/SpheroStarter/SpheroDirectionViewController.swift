//
//  SpheroDirectionViewController.swift
//  SparkPerso
//
//  Created by AL on 01/09/2019.
//  Copyright © 2019 AlbanPerli. All rights reserved.
//

import UIKit

class SpheroDirectionViewController: UIViewController {

    
    var currentSpeed:Double = 0 {
        didSet{
            displayCurrentState()
        }
    }
    var currentHeading:Double = 0 {
        didSet{
            displayCurrentState()
        }
    }
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var collisionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var boltCollision = [UUID]()
        
        for bolt in SharedToyBox.instance.bolts {
            if var boltDetails = SharedToyBox.instance.getBoltDetailsByIdentifier(identifier: bolt.identifier) {
                if (boltDetails.type == "joystick") {
                    if (boltDetails.clan == "enemy") {
                        bolt.setFrontLed(color: .red)
                    } else {
                        bolt.setFrontLed(color: .green)
                    }
                    bolt.sensorControl.enable(sensors: SensorMask.init(arrayLiteral: .accelerometer,.gyro))
                    bolt.sensorControl.interval = 1
                    bolt.setStabilization(state: SetStabilization.State.off)
                    
                    if let boltDetailsToRoll = SharedToyBox.instance.getBoltLinked(link: boltDetails.link),
                       let boltToRoll = SharedToyBox.instance.getBoltByIdentifier(identifier: boltDetailsToRoll.UUID) {
                        bolt.sensorControl.onDataReady = { data in
                            DispatchQueue.main.async {
                                if let accelerometer = data.accelerometer {
                                    if let acceleration = accelerometer.filteredAcceleration {
                                        if let x = acceleration.x, let y = acceleration.y {
                                            let datasConverted = JoystickSpheroInterpreter.convert(x: x, y: y, heading: self.currentHeading)
                                            print("canRoll \(boltToRoll.canRoll)")
                                            if (boltToRoll.canRoll == true) {
                                                if datasConverted.reverse {
                                                    boltToRoll.roll(heading: datasConverted.currentHeading, speed: datasConverted.currentSpeed, rollType: .roll, direction: .reverse)
                                                } else {
                                                    boltToRoll.roll(heading: datasConverted.currentHeading, speed: datasConverted.currentSpeed)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else if (boltDetails.type == "animal" || boltDetails.type == "boat") {
                    bolt.setStabilization(state: SetStabilization.State.on)
                    bolt.setCollisionDetection(configuration: .enabled)
                    
                    let boatUUID = SharedToyBox.instance.getBoltDetailsIdentifierByType(type: "boat")
                    
                    if (boltDetails.type == "animal") {
                        bolt.setFrontLed(color: .blue)
                        bolt.onCollisionDetected = { collisionData in
                            print("collision \(boltDetails.type) \(boltDetails.link)")
                            boltCollision.append(bolt.identifier)
                            DispatchQueue.main.sync {
                                if let boatIdentifier = boatUUID {
                                    if boltCollision.contains(boatIdentifier) {
                                        print("collision avec le bateau")
                                        bolt.canRoll = false
                                        delay(0.5) {
                                            boltCollision = []
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        bolt.setFrontLed(color: .orange)
                        bolt.onCollisionDetected = { collisionData in
                            boltCollision.append(bolt.identifier)
                        }
                    }
                }
            }
        }
    }
    
    func displayCurrentState() {
        stateLabel.text = "Current Speed: \(currentSpeed.rounded())\nCurrent Heading: \(currentHeading.rounded())"
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        currentSpeed = Double(sender.value)
    }
    
    @IBAction func headingValueChanged(_ sender: UISlider) {
        currentHeading = Double(sender.value)
//        print("currentHeading: \(currentHeading)")
        SharedToyBox.instance.bolts.map{ $0.stopRoll(heading: currentHeading) }
        //SharedToyBox.instance.bolt?.stopRoll(heading: currentHeading)
    }
    
    @IBAction func frontClicked(_ sender: Any) {
        SharedToyBox.instance.bolts.map{ $0.roll(heading: currentHeading, speed: currentSpeed) }
//        print("front")
//        SharedToyBox.instance.bolt?.roll(heading: currentHeading, speed: currentSpeed)
    }
    
    @IBAction func leftClicked(_ sender: Any) {
        currentHeading += 30.0
        SharedToyBox.instance.bolts.map{ $0.roll(heading: currentHeading, speed: currentSpeed) }
//        print("left")
//        SharedToyBox.instance.bolt?.roll(heading: currentHeading, speed: currentSpeed)
    }
    
    @IBAction func rightClicked(_ sender: Any) {
        currentHeading -= 30.0
        SharedToyBox.instance.bolts.map{ $0.roll(heading: currentHeading, speed: currentSpeed) }
//        print("right")
//        SharedToyBox.instance.bolt?.roll(heading: currentHeading, speed: currentSpeed)
    }
    
    @IBAction func backClicked(_ sender: Any) {
        SharedToyBox.instance.bolts.map{ $0.roll(heading: currentHeading, speed: currentHeading, rollType: .roll, direction: .reverse) }
//        print("back")
//         SharedToyBox.instance.bolt?.roll(heading: currentHeading, speed: currentHeading, rollType: .roll, direction: .reverse)
    }
    
    @IBAction func stopClicked(_ sender: Any) {
        for bolt in SharedToyBox.instance.bolts {
            bolt.canRoll = false
            bolt.stopRoll(heading: currentHeading)
        }
//        print("stop")
//        SharedToyBox.instance.bolt?.stopRoll(heading: currentHeading)
    }
    
    
    @IBAction func stopFirstSphero(_ sender: UIButton) {
        if let firstSpheroDetails = SharedToyBox.instance.getBoltLinked(link: 1, clan: "animals"),
           let firstSphero = SharedToyBox.instance.getBoltByIdentifier(identifier: firstSpheroDetails.UUID) {
            firstSphero.canRoll = false
        }
    }
    
    @IBAction func stopSecondSphero(_ sender: UIButton) {
        if let secondSpheroDetails = SharedToyBox.instance.getBoltLinked(link: 2, clan: "animals"),
           let secondSphero = SharedToyBox.instance.getBoltByIdentifier(identifier: secondSpheroDetails.UUID) {
            print("sphero 2 stop")
            secondSphero.canRoll = false
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
