//
//  Product.swift
//  Artable
//
//  Created by Mohamed on 3/29/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Product {
    var name: String
    var id: String
    var imageURL: String
    var timeStamp: Timestamp
    var category: String
    var price: Double
    var description: String
    var stock: Int
    
    init (name: String, id: String, imageURL: String, timeStamp: Timestamp, category: String, price: Double, description: String, stock: Int) {
        self.name = name
        self.id = id
        self.imageURL = imageURL
        self.timeStamp = timeStamp
        self.category = category
        self.price = price
        self.description = description
        self.stock = stock
    }
    
    func modelToData() -> [String: Any] {[
        "name" : self.name,
        "id" : self.id,
        "imageURL" : self.imageURL,
        "timeStamp" : self.timeStamp,
        "category" : self.category,
        "price": self.price,
        "description": self.description,
        "stock": self.stock
    ]}

    
    init(data: [String: Any]) {
        self.name = data["name"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
        self.imageURL = data["imageURL"] as? String ?? ""
        self.timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp()
        self.category = data["category"] as? String ?? ""
        self.price = data["price"] as? Double ?? 0.0
        self.description = data["description"] as? String ?? ""
        self.stock = data["imageURL"] as? Int ?? 0

       }
}

extension Product : Equatable {
    static func ==(lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}
