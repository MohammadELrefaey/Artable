//
//  ProductCell.swift
//  Artable
//
//  Created by Mohamed on 3/29/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import FirebaseFirestore

protocol ProductCellDelegate: class {
    func productFavorited(product: Product)
    func prdoductDeleted(product: Product)
}

class ProductCell: UITableViewCell {
 //MARK:-outlets
    @IBOutlet weak var productImg: RoundedImageViews!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    //MARK:- Probertires
    weak var delegat: ProductCellDelegate?
    private var product : Product!
    
    //MARK:-
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK:- actions
    @IBAction func favBtnTapped(_ sender: UIButton) {
        delegat?.productFavorited(product: product)
    }
    @IBAction func AddToCart(_ sender: RoundedButtons) {
        StripeCart.instance.addItemToCart(item: product)
    }
    @IBAction func removeProductBtnTapped(_ sender: Any) {
        delegat?.prdoductDeleted(product: product)
    }

    //MARK:- methods
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(product: Product, delegate: ProductCellDelegate, isAdmin: Bool) {
        self.product = product
        self.delegat = delegate
        productTitle.text = product.name
        if let url = URL(string: product.imageURL) {
            let placeholder = UIImage(named: "placeholder")
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.1))]
            productImg.kf.indicatorType = .activity
            productImg.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
        productPrice.text = "$" + String(product.price)
        
        // Favorite Btn
        if UserServices.instance.favorites.contains(product) {
            favBtn.setImage(UIImage(named: "filled_star"), for: .normal)
        } else {
            favBtn.setImage(UIImage(named: "empty_star"), for: .normal)
        }
        
        // Favorite and delete Btn
        if isAdmin {
            favBtn.isHidden = true
            
        } else {
            deleteBtn.isHidden = true
        }
        
    }
    

}
