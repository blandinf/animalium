//
//  ScrollViewController.swift
//  SparkPerso
//
//  Created by Florian on 14/10/2020.
//  Copyright © 2020 AlbanPerli. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController {
    @IBOutlet weak var myScrollView: UIScrollView!
    
    override public var shouldAutorotate: Bool {
      return false
    }
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
      return .landscapeRight
    }
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
      return .landscapeRight
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
