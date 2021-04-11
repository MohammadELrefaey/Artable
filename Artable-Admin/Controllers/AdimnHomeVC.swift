//
//  ViewController.swift
//  Artable-Admin
//
//  Created by Mohamed on 3/27/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit

class AdminHomeVC: HomeVC {
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
}

