//
//  User.swift
//  Artable
//
//  Created by Mohamed on 4/2/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct User {
    var id: String
    var email: String
    var userName: String
    var stripeID: String
    
    init (id: String, email: String, userName: String, stripeID: String) {
        self.id = id
        self.email = email
        self.userName = userName
        self.stripeID = stripeID
    }
    
    func modelToData() -> [String: Any] {[
        "id" : self.id,
        "email" : self.email,
        "userName" : self.userName,
        "stripeID" : self.stripeID
    ]}

    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.userName = data["userName"] as? String ?? ""
        self.stripeID = data["stripeID"] as? String ?? ""
    }
}
