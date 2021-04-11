//
//  LoginVC.swift
//  Artable
//
//  Created by Mohamed on 3/27/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    //MARK:- Outlets
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK:- Actions
    @IBAction func forgotPasswordBtnPressed(_ sender: UIButton) {
        presentForgetPassVC()
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        loginuser()
    }
    
    @IBAction func ContinueAsGuestBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK:- Private Methods
extension LoginVC {
    
    private func presentForgetPassVC() {
        let vc = ForgotPasswordVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    private func loginuser() {
        //Validatae fields
        guard let email = emailTxtField.text , email.isNotEmpty,
            let password = passwordTxtField.text , password.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Please Fill Out All Fields")
                return
        }
        activityIndicator.startAnimating()

        // delet anonymous user and documnet
        deleteAnonymousUser()
            
        // sign in
        Auth.auth().signIn(withEmail: email, password: password, completion: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.activityIndicator.stopAnimating()
                self.handleFireAuthError(error: error)
                return
            }
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    // delete anonymous user and documnet
    private func deleteAnonymousUser() {
        guard let user = Auth.auth().currentUser  else {return}
        let userRef = Firestore.firestore().collection("users").document(user.uid)
        userRef.delete { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.handleFireAuthError(error: error)
                return
            }
            user.delete(completion: { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    self.activityIndicator.stopAnimating()
                    self.handleFireAuthError(error: error)
                    return
                }
            })
        }
    }
}
