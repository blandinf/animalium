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
        
        let nbBolts = SharedToyBox.instance.bolts.count
        var boltCollision = [Bool]()
        
        SharedToyBox.instance.bolts.map{
            $0.setStabilization(state: SetStabilization.State.on)
            $0.setCollisionDetection(configuration: .enabled)
        }
        SharedToyBox.instance.bolts.map{
            $0.onCollisionDetected = { collisionData in
                boltCollision.append(true)
                DispatchQueue.main.sync {
                    if nbBolts == boltCollision.count {
                        print("Collision de 2 bolts")
                    }else{
                        delay(0.5) {
                            boltCollision = []
                        }
                    }
                    self.collisionLabel.text = "Aïe!!!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.collisionLabel.text = ""
                    }
                }
            }
        }
        
        SharedToyBox.instance.bolts[0].sensorControl.enable(sensors: SensorMask.init(arrayLiteral: .accelerometer,.gyro))
        SharedToyBox.instance.bolts[0].sensorControl.interval = 1
        SharedToyBox.instance.bolts[0].setStabilization(state: SetStabilization.State.off)
        SharedToyBox.instance.bolts[0].sensorControl.onDataReady = { data in
            DispatchQueue.main.async {
                if let accelerometer = data.accelerometer {
                    if let acceleration = accelerometer.filteredAcceleration {
                        if let x = acceleration.x, let y = acceleration.y, let z = acceleration.z {
                            let datasConverted = JoystickInterpreter.convert(x: x, y: y, heading: self.currentHeading)
                            print(datasConverted)
                            if datasConverted.reverse {
                                SharedToyBox.instance.bolts[1].roll(heading: datasConverted.currentHeading, speed: datasConverted.currentSpeed, rollType: .roll, direction: .reverse)
                            } else {
                                SharedToyBox.instance.bolts[1].roll(heading: datasConverted.currentHeading, speed: datasConverted.currentSpeed)
                            }
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
        if SharedToyBox.instance.bolts.count == 2 {
            SharedToyBox.instance.bolts[0].stopRoll(heading: currentHeading)
            SharedToyBox.instance.bolts[1].stopRoll(heading: currentHeading)
        } else {
            SharedToyBox.instance.bolts[0].stopRoll(heading: currentHeading)
        }
//        print("stop")
//        SharedToyBox.instance.bolt?.stopRoll(heading: currentHeading)
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
