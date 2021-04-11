//
//  ProductVC.swift
//  Artable
//
//  Created by Mohamed on 3/29/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ProductVC: UIViewController {
   
    //MARK:- Outlet
    @IBOutlet weak var TableView: UITableView!
    
    //MARK:- Outlet
    var products = [Product]()
    var category: Category!
    var listner: ListenerRegistration!
    var selectedProduct: Product!
    var isFav = false
    var isAdmin = false
    
    //MARK:- life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.delegate = self
        TableView.dataSource = self
        TableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setProductsListner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listner.remove()
        products.removeAll()
        TableView.reloadData()
    }
}

//MARK:- UITableViewDataSource, UITableViewDelegate
extension ProductVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell {
            cell.configure(product: products[indexPath.row], delegate: self, isAdmin: isAdmin)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProduct = products[indexPath.row]
        let vc = ProductDetailsVC()
        vc.product = selectedProduct
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}

//MARK:- Private Methods
extension ProductVC: ProductCellDelegate {
    
    func setProductsListner() {
        
        // dedect this vc productVC or favoritesVC
        var ref: Query!
        if isFav {
             ref = Firestore.firestore().collection("users").document(UserServices.instance.user.id).collection("favorites")
        } else {
            ref = Firestore.firestore().product(category: category.id)
        }
        
        
        listner = ref.addSnapshotListener({ (snap, error) in
                if let error = error {
                  debugPrint(error)
                    return
                }
                snap?.documentChanges.forEach({ (change) in
                    let product = Product.init(data: change.document.data())
                    
                    switch change.type {
                        case .modified : self.onDocumentModified(change: change, product: product)
                        case .added : self.onDocumentAdded(change: change, product: product)
                        case .removed : self.onDocumentRemoved(change: change)
                    }
                })
            })
        }
        
        func onDocumentAdded(change: DocumentChange, product: Product) {
            let newIndex = Int(change.newIndex)
            products.insert(product, at: newIndex)
            TableView.insertRows(at: [IndexPath(item: newIndex, section: 0)], with: UITableView.RowAnimation.fade)
        }
        
        func onDocumentModified(change: DocumentChange, product: Product) {
            let newIndex = Int(change.newIndex)
            let oldIndex = Int(change.oldIndex)
            
            if newIndex == oldIndex {
                products[oldIndex] = product
                TableView.reloadRows(at: [IndexPath(item: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
                
                products.remove(at: oldIndex)
                products.insert(product, at: newIndex)
                TableView.moveRow(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
            }
        }
        
        func onDocumentRemoved(change: DocumentChange) {
            let oldIndex = Int(change.oldIndex)
            products.remove(at: oldIndex)
            TableView.deleteRows(at: [IndexPath(item: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
            
        }
    
    func productFavorited(product: Product) {
        UserServices.instance.favoriteSelected(product: product)
        guard let index = products.firstIndex(of: product) else {return}
        TableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func prdoductDeleted(product: Product) {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete this product?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (buttonTapped) in
                Firestore.firestore().collection("products").document(product.id).delete { (error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        self.handleFireAuthError(error: error)
                        return
                    }
                }
            }))
            present(alert, animated: true, completion: nil)
    }

}
