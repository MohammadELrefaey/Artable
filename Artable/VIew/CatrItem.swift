//
//  CatrItem.swift
//  Artable
//
//  Created by Mohamed on 4/4/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit
import Kingfisher

protocol CartItemDelegate: class {
    func deleteItem()
}

class CatrItem: UITableViewCell {
    //MARK:- Outlets
    @IBOutlet weak var itemImg: RoundedImageViews!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    
    //MARK:- properties
    var delegate: CartItemDelegate?
    var product: Product!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK:- actions
    @IBAction func deleteItemBtnTapped(_ sender: Any) {
        StripeCart.instance.removeItemFromCart(item: product)
        delegate?.deleteItem()
    }
    
    //MARK:- methods
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(item: Product, delegate: CartItemDelegate) {
        self.delegate = delegate
        self.product = item
        itemTitle.text = item.name
        if let url = URL(string: item.imageURL) {
            let placeholder = UIImage(named: "placeholder")
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.1))]
            itemImg.kf.indicatorType = .activity
            itemImg.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
        itemPrice.text = "$" + String(item.price)
    }
}
