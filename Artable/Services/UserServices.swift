//
//  UserServices.swift
//  Artable
//
//  Created by Mohamed on 4/3/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import Foundation
import Firebase

 class UserServices {
   static let instance = UserServices()
    
    var user = User(id: "", email: "", userName: "", stripeID: "")
    var favorites = [Product]()
    var userListner : ListenerRegistration? = nil
    var favListner : ListenerRegistration? = nil
    let auth = Auth.auth()
    let db = Firestore.firestore()
    
    var isGuset : Bool  {
        guard let authUser = auth.currentUser else {
            return true
        }
        
        if authUser.isAnonymous {
            return false
        } else {
            return true
        }
    }
    
    
    func getCurrentUser() {
        //get user
        guard let user = auth.currentUser else { return }
        let userRef = db.collection("users").document(user.uid)
        userListner = userRef.addSnapshotListener { (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            guard let data = snap?.data() else { return }
            self.user = User(data: data)
        }
        
        //get user favorites
        let favsRef = userRef.collection("favorites")
        
        favListner = favsRef.addSnapshotListener { (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
             snap?.documents.forEach({ (snap) in
                let data = snap.data()
                let product = Product(data: data)
                self.favorites.append(product)
            })
        }
    }
    
    func favoriteSelected(product: Product) {
        let favRef = db.collection("users").document(user.id).collection("favorites")
        
        if favorites.contains(product) {
            //remove favorite
            favorites.removeAll{$0 == product}
            favRef.document(product.id).delete()
        } else {
            //add favorite
            favorites.append(product)
            let data = product.modelToData()
            favRef.document(product.id).setData(data)
        }
    }
    
    
    func logUserOut() {
        userListner?.remove()
        userListner = nil
        favListner?.remove()
        favListner = nil
        user = User(id: "", email: "", userName: "", stripeID: "")
        favorites.removeAll()
    }
    
    
}
