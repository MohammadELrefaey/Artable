//
//  StripeCart.swift
//  Artable
//
//  Created by Mohamed on 4/5/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import Foundation

class StripeCart {
    static let instance = StripeCart()
    
    var cartItems = [Product]()
    private let stripeCreditCardCut = 0.029
    private let flatFeeCents = 30
    var shippingFees = 0
    
    
    // Variables forsubtotal, processing fees , total
        var subtotal: Int {
        var amount = 0
        for item in cartItems {
            let pricePennies = Int(item.price*100)
            amount += pricePennies
        }
        return amount
    }
    
    var proccessingFees: Int {
        if subtotal == 0 {
            return 0
        }
        let sub = Double(subtotal)
        let feeaAndSub = Int(sub * stripeCreditCardCut) + flatFeeCents
        return feeaAndSub
    }
    
    var total: Int {
        return subtotal + proccessingFees + shippingFees
    }
    
    func addItemToCart(item: Product) {
        cartItems.append(item)
    }
    
    func removeItemFromCart(item: Product) {
        if let index = cartItems.firstIndex(of: item) {
            cartItems.remove(at: index)
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
}
