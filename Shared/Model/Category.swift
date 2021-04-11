//
//  Categories.swift
//  Artable
//
//  Created by Mohamed on 3/29/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Category {
    var name: String
    var id: String
    var imageURL: String
    var isActive: Bool = true
    var timeStamp: Timestamp
    
    init (name: String, id: String, imageURL: String, isActive: Bool, timeStamp: Timestamp) {
        self.name = name
        self.id = id
        self.imageURL = imageURL
        self.isActive = isActive
        self.timeStamp = timeStamp
    }
    
    func modelToData() -> [String: Any] {[
        "name" : self.name,
        "id" : self.id,
        "imageURL" : self.imageURL,
        "isActive" : self.isActive,
        "timeStamp" : self.timeStamp
    ]}
    
    init(data: [String: Any]) {
        self.name = data["name"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
        self.imageURL = data["imageURL"] as? String ?? ""
        self.isActive = data["isActive"] as? Bool ?? true
        self.timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp()
    }
}
