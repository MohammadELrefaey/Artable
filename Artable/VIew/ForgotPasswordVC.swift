//
//  ForgotPasswordVC.swift
//  Artable
//
//  Created by Mohamed on 3/29/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit
import Firebase
class ForgotPasswordVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var emailTxtField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK:- actions
    @IBAction func resetPassBtnPressed(_ sender: RoundedButtons) {
        guard let email = emailTxtField.text, email.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Enter The Email")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                debugPrint(error)
                self.handleFireAuthError(error: error)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: RoundedButtons) {
        dismiss(animated: true, completion: nil)
    }
}
