//
//  StripeApi.swift
//  Artable
//
//  Created by Mohamed on 4/6/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import Foundation
import Stripe
import FirebaseFunctions

class StripeApi: NSObject, STPCustomerEphemeralKeyProvider {
    static let instance =  StripeApi()
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let data = [
            "stripe_version": apiVersion,
            "customer_id": UserServices.instance.user.stripeID
        ]
        Functions.functions().httpsCallable("createEphemeralKey").call(data) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let key = result?.data as? [String: Any] else {
                completion(nil, nil)
                return
            }
            completion(key, nil)
        }
        
    }
    
    
    
    
    
    
    
}
