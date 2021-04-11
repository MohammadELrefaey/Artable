//
//  AddCategoryVC.swift
//  Artable-Admin
//
//  Created by Mohamed on 4/1/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AddEditCategoryVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var categoryImg: RoundedImageViews!
    @IBOutlet weak var categoryName: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addCategoryBtnTapped: RoundedButtons!
    
    //MARK:- Properties
    var categoryToEdit: Category?
    
    //MARK:-LIfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageGesture()
        categoryImg.image = UIImage(named: "camera")
        editCategory()
    }
    
    //MARK:- Actions
    @IBAction func addCategoryBtnTapped(_ sender: RoundedButtons) {
        uploadImageThenDocument()
    }
}

//MARK:- Private methods
extension AddEditCategoryVC {
    private func profileImageGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.profileImgTapped))
        categoryImg.addGestureRecognizer(tap)
        categoryImg.isUserInteractionEnabled = true
    }
    
    @objc func profileImgTapped(sender: UITapGestureRecognizer) {
        activityIndicator.startAnimating()
        showImagePickerController()
    }
    
    private func uploadImageThenDocument() {
        activityIndicator.startAnimating()
            
        guard let image = categoryImg.image, image != UIImage(named: "camera")  else {
            self.activityIndicator.stopAnimating()
            simpleAlert(title: "Error", msg: "Must add category image")
            return
        }

        
        guard let name = categoryName.text, name.isNotEmpty else {
            self.activityIndicator.stopAnimating()
            simpleAlert(title: "Error", msg: "Must add category name")
            return
        }
        let data = image.jpegData(compressionQuality: 0.2)
        
        let imageRef = Storage.storage().reference().child("/categoryImages/ \(name).jpg")
        
        let metaData = StorageMetadata()
        
        imageRef.putData(data!, metadata: metaData) { (metaData, error) in
            self.activityIndicator.stopAnimating()
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "Error", msg: "Unable to upload image")
                return
            }
            
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }

                guard let url = url else { return }
                self.addCategory(url: url)
            }
        }
    }
    
    private func addCategory(url: URL) {
        let docRef: DocumentReference!
        let url = url.absoluteString
        
        // if ediiting
        if let categoryToEdit = categoryToEdit {
            docRef = Firestore.firestore().collection("categories").document(categoryToEdit.id)
        }
            
        // id new category
        else {
            docRef = Firestore.firestore().collection("categories").document()
        }
        
        let category = Category.init(name: categoryName.text!, id: docRef.documentID , imageURL: url, isActive: true, timeStamp: Timestamp())
        let data =  category.modelToData()


        docRef.setData(data) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "Error", msg: "Can't add category")
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func editCategory() {
        if let category = categoryToEdit {
            categoryName.text = category.name
            if let url = URL(string: category.imageURL) {
                categoryImg.kf.setImage(with: url)
                categoryImg.contentMode = .scaleAspectFill
            }
            addCategoryBtnTapped.setTitle("Save Changes", for: .normal)
        }
    }
    
}
//MARK:- Image Picker Extension
extension AddEditCategoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
        activityIndicator.perform(#selector(activityIndicator.stopAnimating), with: nil, afterDelay: 1)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            categoryImg.contentMode = .scaleAspectFill
            categoryImg.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            categoryImg.contentMode = .scaleAspectFill
            categoryImg.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        activityIndicator.stopAnimating()
        dismiss(animated: true, completion: nil)

    }
    
}
