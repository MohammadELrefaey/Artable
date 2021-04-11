//
//  ViewController.swift
//  Artable
//
//  Created by Mohamed on 3/27/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class HomeVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var logInOutBtn: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:- Properties
    var categories = [Category]()
    var selectedCategory: Category!
    var listner: ListenerRegistration!
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { (result, error) in
                if let error = error {
                    debugPrint(error)
                    self.handleFireAuthError(error: error)
                }
                self.createUserDocumnet(uid: (result?.user.uid)!)
            }
        }
    }
    
    private func createUserDocumnet(uid: String) {
         let userRef = Firestore.firestore().collection("users").document(uid)
         let user = User(id: uid, email: "", userName: "", stripeID: "")
         let data = user.modelToData()
         userRef.setData(data)
     }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserServices.instance.getCurrentUser()
        if let user = Auth.auth().currentUser , !user.isAnonymous {
            logInOutBtn.title = "Logout"
        } else {
            logInOutBtn.title = "Login"
        }
        collectionListner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listner.remove()
        categories.removeAll()
        collectionView.reloadData()
    }

    //MARK:- Actions
    @IBAction func logInOutBtnPressed(_ sender: UIBarButtonItem) {
        
        guard let user = Auth.auth().currentUser else {return}
        
        if user.isAnonymous {
            presentLoginVC()
        } else {
            do {
                try Auth.auth().signOut()
                UserServices.instance.logUserOut()
                //sign in anonymously
                Auth.auth().signInAnonymously { (resutlt, error) in
                    if let error = error {
                        debugPrint(error)
                        self.handleFireAuthError(error: error)
                    }
                    // creat anonymous user documnet
                    self.createUserDocumnet(uid: (resutlt?.user.uid)!)
                    self.presentLoginVC()
                }
            } catch {
                debugPrint(error)
            }
        }
    }
    
    @IBAction func favBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "toFavsVC", sender: self)
    }
}
 
//MARK:- Outlets
extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell {
            cell.configure(category: categories[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let cellWidth = (width - 30) / 2
        let cellHeght = cellWidth * 1.5
        
        return CGSize(width: cellWidth, height: cellHeght)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.item]
        performSegue(withIdentifier: "toProductVC", sender: self)
    }
    
}
//MARK:- Private Methods
extension HomeVC {
    private func setupTableView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
    }
    
   private func presentLoginVC() {
        let Storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginVC = Storyboard.instantiateViewController(withIdentifier: "loginVC")
        present(loginVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // product row tapped
        if segue.identifier == "toProductVC" {
            if let destination = segue.destination as? ProductVC {
                destination.category = selectedCategory
            }
        }
        // favorite btn tapped
        else if segue.identifier == "toFavsVC" {
            //Check if logged in
            if let destination = segue.destination as? ProductVC {
                destination.isFav = true
                destination.category = selectedCategory
            }
        }
}
    
    private func collectionListner() {
        listner = Firestore.firestore().Category.addSnapshotListener({ (snap, error) in
            if let error = error {
              debugPrint(error)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let category = Category.init(data: change.document.data())
                
                switch change.type {
                    case .modified : self.onDocumentModified(change: change, category: category)
                    case .added : self.onDocumentAdded(change: change, category: category)
                    case .removed : self.onDocumentRemoved(change: change)
                }
            })
        })
    }
    
   private func onDocumentAdded(change: DocumentChange, category: Category) {
        let newIndex = Int(change.newIndex)
        categories.insert(category, at: newIndex)
        collectionView.insertItems(at: [IndexPath(item: newIndex, section: 0)])
    }
    
   private func onDocumentModified(change: DocumentChange, category: Category) {
        let newIndex = Int(change.newIndex)
        let oldIndex = Int(change.oldIndex)
        
        if newIndex == oldIndex {
            categories[oldIndex] = category
            collectionView.reloadItems(at: [IndexPath(item: oldIndex, section: 0)])
        }
        categories.remove(at: oldIndex)
        categories.insert(category, at: newIndex)
        collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
    }
    
    private func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        categories.remove(at: oldIndex)
        collectionView.deleteItems(at: [IndexPath(item: oldIndex, section: 0)])
        
    }
    
}
