//
//  AdminProductVC.swift
//  Artable-Admin
//
//  Created by Mohamed on 4/2/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class AdminProductVC: ProductVC {
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK:- Actions
    @IBAction func addProductBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "toAddEditProductVC", sender: self)
    }
    @IBAction func deleteCategoryBtnTapped(_ sender: Any) {
        deleteCategory()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProduct = products[indexPath.row]
        performSegue(withIdentifier: "toAddEditProductVC", sender: self)
        selectedProduct = nil
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell {
            cell.configure(product: products[indexPath.row], delegate: self, isAdmin: true)
            return cell
        }
        return UITableViewCell()
    }
    

}

//MARK:- Private methods
extension AdminProductVC {
    private func deleteCategory() {
        // pop delete alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete this category?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (buttonTapped) in
            // delet category  firestore documnet
            Firestore.firestore().collection("categories").document(self.category.id).delete { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    self.handleFireAuthError(error: error)
                    return
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }))
            present(alert, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // edit category btn Tapped
        if segue.identifier == "toAddEditVC" {
            if let destination = segue.destination as? AddEditCategoryVC {
                destination.categoryToEdit = category
            }
        }
        // edit product btn tapped
        else if segue.identifier == "toAddEditProductVC" {
            if let destination = segue.destination as? AddEditProductVC {
                destination.category = category
                destination.productToEdit = selectedProduct
            }
        }
    }

}
