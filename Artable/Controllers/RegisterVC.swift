//
//  RegisterVC.swift
//  Artable
//
//  Created by Mohamed on 3/27/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    
//MARK:- outlets
    @IBOutlet weak var userNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var confirmPasswordTxtField: UITextField!
    @IBOutlet weak var confirmPassCheckImg: UIImageView!
    @IBOutlet weak var passChecImg: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTxtField.addTarget(self, action: #selector(textFieldEdited(_:)), for:UIControl.Event.editingChanged)
        confirmPasswordTxtField.addTarget(self, action: #selector(textFieldEdited(_:)), for:UIControl.Event.editingChanged)
    }
    //MARK:- actions
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        registerUser()
    }
}

//MARK:- private methods
extension RegisterVC {
    
    //update anonymous user documnet
   private func updateUserDocumnet(user: User) {
        let userRef = Firestore.firestore().collection("users").document(user.id)
        let data = user.modelToData()
        userRef.updateData(data)
    }
    
    private func registerUser() {
        activityIndicator.startAnimating()

        // user validations
        guard let userName = userNameTxtField.text , userName.isNotEmpty,
            let email = emailTxtField.text , email.isNotEmpty,
            let password = passwordTxtField.text , password.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Please Fill Out All Fields")
                return
        }
        guard let confirmPass = confirmPasswordTxtField.text , confirmPass == password else {
            simpleAlert(title: "Error", msg: "Password Dont Match")
            return
        }
        
        // link anonymous user with new user
        guard let authUser = Auth.auth().currentUser else {return}
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        authUser.link(with: credential) { (result, error) in
            
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                debugPrint(error)
                self.handleFireAuthError(error: error)
                return
            }
            guard  let user = result?.user else {return}
            let stripeID = UserServices.instance.user.stripeID
            let firUser = User.init(id: user.uid, email: email, userName: userName, stripeID: stripeID)
            self.updateUserDocumnet(user: firUser)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // confirm password logic
    @objc private func textFieldEdited( _ textField: UITextField) {
        guard let password = passwordTxtField.text else {return}
        
        if textField == confirmPasswordTxtField {
            passChecImg.isHidden = false
            confirmPassCheckImg.isHidden = false
        }
        else if password.isEmpty == true {
           passChecImg.isHidden = true
           confirmPassCheckImg.isHidden = true
            confirmPasswordTxtField.text = ""
        }
        
        if confirmPasswordTxtField.text == passwordTxtField.text {
            passChecImg.image = UIImage(named: "green_check")
            confirmPassCheckImg.image = UIImage(named: "green_check")
        } else {
            passChecImg.image = UIImage(named: "red_check")
            confirmPassCheckImg.image = UIImage(named: "red_check")
        }
    }
}
