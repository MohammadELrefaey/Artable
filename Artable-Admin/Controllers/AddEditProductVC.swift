//
//  AddEditProductVC.swift
//  Artable-Admin
//
//  Created by Mohamed on 4/2/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class AddEditProductVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var productNameTxtField: UITextField!
    @IBOutlet weak var priceTxtField: UITextField!
    @IBOutlet weak var DescriptionTxtField: UITextView!
    @IBOutlet weak var addProductBtn: RoundedButtons!
    @IBOutlet weak var productImg: RoundedImageViews!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:- Properties
    var productToEdit: Product?
    var category: Category!
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageGesture()
        productImg.image = UIImage(named: "camera")
        editProduct()
    }
        
    //MARK:- Actions
    @IBAction func addPRoductBtnTapped(_ sender: RoundedButtons) {
        uploadImageThenDocument()
    }
}

//MARK:- Private methods
extension AddEditProductVC {
    private func profileImageGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.ProductImgTapped))
        productImg.addGestureRecognizer(tap)
        productImg.isUserInteractionEnabled = true
    }
    
    @objc func ProductImgTapped(sender: UITapGestureRecognizer) {
        activityIndicator.startAnimating()
        showImagePickerController()
    }
    
    private func uploadImageThenDocument() {
        activityIndicator.startAnimating()
            
        guard let image = productImg.image, image != UIImage(named: "camera"),
            let name = productNameTxtField.text, name.isNotEmpty,
            let priceString = priceTxtField.text, priceString.isNotEmpty,
            let description = DescriptionTxtField.text, description.isNotEmpty else {
            self.activityIndicator.stopAnimating()
            simpleAlert(title: "Missing Fields", msg: "Must fill out all fields")
            return
        }
        // upload image
        let data = image.jpegData(compressionQuality: 0.2)
        
        let imageRef = Storage.storage().reference().child("/productsImages/ \(name).jpg")
        
        let metaData = StorageMetadata()
        
        imageRef.putData(data!, metadata: metaData) { (metaData, error) in
            self.activityIndicator.stopAnimating()
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "Error", msg: "Unable to upload image")
                return
            }
            // get image url
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }

                guard let url = url else { return }
                self.addProduct(url: url)
            }
        }
    }
    
    private func addProduct(url: URL) {
        let docRef: DocumentReference!
        let url = url.absoluteString
        
        // if ediiting
        if let productToEdit = productToEdit {
            docRef = Firestore.firestore().collection("products").document(productToEdit.id)
        }
        // id new category
        else {
            docRef = Firestore.firestore().collection("products").document()
        }
        let product = Product.init(name: productNameTxtField.text!, id: docRef.documentID, imageURL: url, timeStamp: Timestamp(), category: category.id, price: Double(priceTxtField.text!)!, description: DescriptionTxtField.text, stock: 0)
        let data =  product.modelToData()


        docRef.setData(data) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "Error", msg: "Can't add Product")
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func editProduct() {
        if let product = productToEdit {
            productNameTxtField.text = product.name
            priceTxtField.text = String(product.price)
            DescriptionTxtField.text = product.description
            if let url = URL(string: product.imageURL) {
                productImg.kf.setImage(with: url)
                productImg.contentMode = .scaleAspectFill
            }
            addProductBtn.setTitle("Save Changes", for: .normal)
        }

    }
    
}
//MARK:- Image Picker Extension
extension AddEditProductVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            productImg.contentMode = .scaleAspectFill
            productImg.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            productImg.contentMode = .scaleAspectFill
            productImg.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        activityIndicator.stopAnimating()
        dismiss(animated: true, completion: nil)

    }
    
}
