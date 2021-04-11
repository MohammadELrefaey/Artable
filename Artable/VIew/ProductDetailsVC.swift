//
//  productDetailsVC.swift
//  Artable
//
//  Created by Mohamed on 3/31/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit
import Kingfisher

class ProductDetailsVC: UIViewController {

    //MARK:- outlets
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var desriptionLbl: UILabel!
    @IBOutlet weak var ProductPriceLbl: UILabel!
    @IBOutlet weak var bgView: UIVisualEffectView!
    //MARK:- properties
    var product: Product!
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        productNameLbl.text = product.name
        ProductPriceLbl.text = "$" + String(product.price)
        desriptionLbl.text = product.description
        if let url = URL(string: product.imageURL) {
            let placeholder = UIImage(named: "placeholder")
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.1))]
            productImg.kf.indicatorType = .activity
            productImg.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
    }

    //MARK:- Actions
    @IBAction func addToCartBtnPressed(_ sender: RoundedButtons) {
        StripeCart.instance.addItemToCart(item: product)
        print("aho")
        print(StripeCart.instance.cartItems)
    }
    @IBAction func KeepShoppingBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
