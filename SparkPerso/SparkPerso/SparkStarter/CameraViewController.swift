//
//  CameraViewController.swift
//  SparkPerso
//
//  Created by AL on 14/01/2018.
//  Copyright © 2018 AlbanPerli. All rights reserved.
//

import UIKit
import DJISDK
import VideoPreviewer
import AVFoundation

//import ImageDetect

class CameraViewController: UIViewController {

    @IBOutlet weak var extractedFrameImageView: UIImageView!
    let spark = DJISDKManager.product() as? DJIAircraft
    
    var limitPos = (x: 0, y: 0)
    var realPos = (x: 500, y: 500)
    var isAllowToMove = true
    var index = 1
    var boltCollisions = [UUID]()
    
    @IBOutlet var akialoas: [UIImageView]!
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var flashImage: UIImageView!
    
    @IBOutlet weak var flashView: UIView!
    @IBOutlet weak var myScrollView: UIScrollView!
    let prev1 = VideoPreviewer()
    @IBOutlet weak var cameraView: UIView!
    
    let prev2 = VideoPreviewer()
    @IBOutlet weak var camera2View: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let soundURL = Bundle.main.url(forResource: "picture", withExtension: "wav") else {
            print("nok")
            return
        }

        myScrollView.setValue(2.0, forKeyPath: "contentOffsetAnimationDuration")

        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            guard let player = player else {
                print("nok2")
                return
            }

            print("player \(player)")
            player.prepareToPlay()
            
            if let buzzerDetails = SharedToyBox.instance.getBoltDetailsByTypeAndActivity(type: "buzzer", activity: "bird") {
                print(buzzerDetails)
                if let buzzer = SharedToyBox.instance.getBoltByIdentifier(identifier: buzzerDetails.UUID) {
                    print(buzzer)
                    buzzer.setFrontLed(color: .orange)
                    buzzer.sensorControl.enable(sensors: SensorMask.init(arrayLiteral: .accelerometer,.gyro))
                    buzzer.sensorControl.interval = 1
                    buzzer.setStabilization(state: SetStabilization.State.off)
                    buzzer.setCollisionDetection(configuration: .enabled)
                    buzzer.onCollisionDetected = { collisionData in
                        self.test()
                        player.play()
                    }
                }
            }
            
            if let joystickDrone = SharedToyBox.instance.getBoltDetailsByTypeAndActivity(type: "joystick", activity: "bird") {
                if let joystick = SharedToyBox.instance.getBoltByIdentifier(identifier: joystickDrone.UUID) {
                    joystick.setFrontLed(color: .green)
                    joystick.sensorControl.enable(sensors: SensorMask.init(arrayLiteral: .accelerometer,.gyro))
                    joystick.sensorControl.interval = 1
                    joystick.setStabilization(state: SetStabilization.State.off)
                    joystick.sensorControl.onDataReady = { data in
                        DispatchQueue.main.async { [self] in
                            if let accelerometer = data.accelerometer {
                                if let acceleration = accelerometer.filteredAcceleration {
                                    if let x = acceleration.x, let y = acceleration.y {
                                        let datasConverted = JoystickSparkInterpreter.convert(x: x, y: y, currentPos: self.limitPos)
                                        self.updatePosition(newX: datasConverted.newX, newY: datasConverted.newY, action: datasConverted.action)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            hideBirds()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func test () {
        DispatchQueue.main.async {
            self.flashView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.flashView.isHidden = true
            }
        }
    }
    
    func updatePosition (newX: Int, newY: Int, action: Movement.Direction) {
        if (isAllowToMove) {
            if newY == 2 || newX == 2 || newY == -2 || newX == -2 {
                return
            }
            
            if limitPos != (newX, newY) {
                limitPos = (newX, newY)
                print(limitPos)
                print(realPos)
                isAllowToMove = false
                
                if let mySpark = spark {
                    switch action {
                        case Movement.Direction.front:
                            mySpark.mobileRemoteController?.rightStickVertical = 0.3
                            if (realPos.y - 500 >= 0) {
                                realPos = (realPos.x, realPos.y - 500)
                                self.myScrollView.setContentOffset(CGPoint(x: realPos.x, y: realPos.y), animated: true)
                            }
                        case Movement.Direction.back:
                            mySpark.mobileRemoteController?.rightStickVertical = -0.3
                            realPos = (realPos.x, realPos.y + 500)
                            self.myScrollView.setContentOffset(CGPoint(x: realPos.x, y: realPos.y), animated: true)
                        case Movement.Direction.left:
                            mySpark.mobileRemoteController?.rightStickHorizontal = -0.3
                            if (realPos.x - 500 >= 0) {
                                realPos = (realPos.x - 500, realPos.y)
                                self.myScrollView.setContentOffset(CGPoint(x: realPos.x, y: realPos.y), animated: true)
                            }
                        case Movement.Direction.right:
                            mySpark.mobileRemoteController?.rightStickHorizontal = 0.3
                            realPos = (realPos.x + 500, realPos.y)
                            self.myScrollView.setContentOffset(CGPoint(x: realPos.x, y: realPos.y), animated: true)
                        case Movement.Direction.nothing:
                            self.stop()
                        default:
                            return
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.stop()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isAllowToMove = true
                }
            }
        }
    }
    
    func hideBirds () {
        if (index <= 12) {
            print("akiloas \(akialoas)")
            var images = self.akialoas.filter { $0.tag == index}

            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                for image in images {
                    image.isHidden = true
                }
                self.index = self.index + 1
                self.hideBirds()
            }
        }
    }
    
    @IBAction func stop(_ sender: UIButton) {
        self.stop()
    }
    
    @IBAction func decoller(_ sender: UIButton) {
        print("take off")
        GimbalManager.shared.lookUnder()
        if let mySpark = DJISDKManager.product() as? DJIAircraft {
            self.myScrollView.setContentOffset(CGPoint(x: realPos.x, y: realPos.y), animated: true)
            if let flightController = mySpark.flightController {
                flightController.startTakeoff(completion: { (err) in
                    print(err.debugDescription)
                })
            }
        }
        let h: CGFloat = cameraView.frame.size.height
        let w: CGFloat = cameraView.frame.size.width
        let scale: CGFloat = 1.7
        
        self.myScrollView.setContentOffset(CGPoint(x: realPos.x, y: realPos.y), animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseInOut], animations: {
                self.cameraView.transform = self.cameraView.transform.scaledBy(x: scale, y: scale)
            }, completion: { finish in })
        }
    }

    @IBAction func atterrir(_ sender: UIButton) {
        print("landing ")
        if let mySpark = DJISDKManager.product() as? DJIAircraft {
            if let flightController = mySpark.flightController {
                flightController.startLanding(completion: { (err) in
                    print(err.debugDescription)
                })
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
    
    override public var shouldAutorotate: Bool {
      return false
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
      return .landscapeRight
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
      return .landscapeRight
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = DJISDKManager.product() {
            if let camera = self.getCamera(){
                camera.delegate = self
                cameraView.pinEdges(to: view)
                self.setupVideoPreview()
            }
            
            GimbalManager.shared.setup(withDuration: 1.0, defaultPitch: -28.0)
            GimbalManager.shared.lookUnder()

            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func lookFront(_ sender: Any) {
        GimbalManager.shared.lookFront()
    }
    
    @IBAction func lookUnder(_ sender: Any) {
        GimbalManager.shared.lookUnder()
    }
    @IBAction func startStopCameraButtonClicked(_ sender: UIButton) {
        
        self.prev1?.snapshotThumnnail { (image) in
            if let img = image {
//                print(img.size)
                self.extractedFrameImageView.image = img
                
                let prediction = ImageRecognition.shared.predictUsingCoreML(image: img)
                print(prediction?.1)
                
//                if let dataImg = UIImagePNGRepresentation(img){
//                    let strId = UUID().uuidString
//                    var url = getDocumentsDirectory()
//                    let imgUrl = url.appendingPathComponent("MonNom"+strId+".png")
//                    try! dataImg.write(to: imgUrl)
//                }
                
                
            }
        }
        
        /*
         Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.prev1?.snapshotThumnnail { (image) in
                
                if let img = image {
                    print(img.size)
                    // Resize it and put it in a neural network! :)
                
                    if let infos = ImageRecognition.shared.predictUsingCoreML(image: img){
                        self.extractedFrameImageView.image = infos.0
                        self.resultLabel.text = infos.1
                    }else{
                        self.extractedFrameImageView.image = nil
                        self.resultLabel.text = ""
                    }
                    
                    /*
                    img.detector.crop(type: DetectionType.face) { result in
                        DispatchQueue.main.async { [weak self] in
                            switch result {
                            case .success(let croppedImages):
                                // When the `Vision` successfully find type of object you set and successfuly crops it.
                                self?.extractedFrameImageView.image = croppedImages.first
                            case .notFound:
                                // When the image doesn't contain any type of object you did set, `result` will be `.notFound`.
                                print("Not Found")
                            case .failure(let error):
                                // When the any error occured, `result` will be `failure`.
                                print(error.localizedDescription)
                            }
                        }
                    }
                     */
                    
                }
            }
        }
        */
    }
    
    @IBAction func captureModeValueChanged(_ sender: UISegmentedControl) {
        
    }
    
    func getCamera() -> DJICamera? {
        // Check if it's an aircraft
        if let mySpark = DJISDKManager.product() as? DJIAircraft {
             return mySpark.camera
        }
        
        return nil
    }
    
    
    func setupVideoPreview() {
        
        // Prev1 est de type VideoPreviewer
        // Camera view est une view liée depuis le storyboard
        
        prev1?.setView(self.cameraView)
//        self.cameraView.pinEdges(to: view)
        /*
        // ...
        // plus loin
        // ...
        // ReceivedData est l'équivalent de ton callBack de reception
        WebSocketManager.shared.receivedData{ data in
            // On extrait les bytes de data sous la forme d'un pointeur sur UInt8
            data.withUnsafeBytes { (bytes:UnsafePointer<UInt8>) in
                // On push ces fameux bytes dans la vue
                prev1?.push(UnsafeMutablePointer(mutating: bytes), length: Int32(data.count))
            }
        }
        */
        
        
        //prev2?.setView(self.camera2View)
        //VideoPreviewer.instance().setView(self.cameraView)
        if let _ = DJISDKManager.product(){
            let video = DJISDKManager.videoFeeder()
            
            DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        }
        prev1?.start()
        //prev2?.start()
        //VideoPreviewer.instance().start()
    }
    
    func resetVideoPreview() {
        prev1?.unSetView()
       // prev2?.unSetView()
        DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let camera = self.getCamera() {
            camera.delegate = nil
        }
        self.resetVideoPreview()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CameraViewController:DJIVideoFeedListener {
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
//        print([UInt8](videoData).count)
        
        videoData.withUnsafeBytes { (bytes:UnsafePointer<UInt8>) in
            prev1?.push(UnsafeMutablePointer(mutating: bytes), length: Int32(videoData.count))
            prev2?.push(UnsafeMutablePointer(mutating: bytes), length: Int32(videoData.count))
        }
        
    }

}

extension CameraViewController:DJISDKManagerDelegate {
    func appRegisteredWithError(_ error: Error?) {
        
    }
    
    
}

extension CameraViewController:DJICameraDelegate {
    
}

