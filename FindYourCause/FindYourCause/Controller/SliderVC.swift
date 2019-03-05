//
//  SliderVC.swift
//  FindYourCause
//
//  Created by Laksh on 02/03/19.
//  Copyright © 2019 Laksh. All rights reserved.
//

import UIKit

class SliderVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.revealViewController()?.rearViewRevealWidth = self.view.frame.size.width-60
    }
    

   
}
