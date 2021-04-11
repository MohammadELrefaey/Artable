//
//  CheckoutVC.swift
//  Artable
//
//  Created by Mohamed on 4/5/21.
//  Copyright © 2021 Refa3y. All rights reserved.
//

import UIKit
import Stripe

class CheckoutVC: UIViewController {
    //MARK:- outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subTotalLbl: UILabel!
    @IBOutlet weak var proccessingFeeLbl: UILabel!
    @IBOutlet weak var TotalLbl: UILabel!
    @IBOutlet weak var shippingFeeLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:- properties
    var items = StripeCart.instance.cartItems
    var paymentContext : STPPaymentContext!
    var isSetShipping = true

    //MARK:- life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        setupTableView()
        setupStripeConfig()
    }
    
    @IBAction func paymentMethodBtn(_ sender: Any) {
        paymentContext.pushPaymentOptionsViewController()
    }
    
    @IBAction func shippingMethodBtn(_ sender: Any) {
        paymentContext.pushShippingViewController()
    }
    
    @IBAction func PlaceOrderBtnTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        simpleAlert(title: "Done", msg: "You order is placed")
        activityIndicator.stopAnimating()
    }
    
}

//MARK:- UITableViewDataSource, UITableViewDelegate
extension CheckoutVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "CatrItem", for: indexPath) as? CatrItem {
            cell.configureCell(item: items[indexPath.row], delegate: self)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    
}

//MARK:- private methods
extension CheckoutVC: CartItemDelegate  {
    func deleteItem() {
        items =  StripeCart.instance.cartItems
        paymentContext.paymentAmount = StripeCart.instance.total
        tableView.reloadData()
        setupLabels()
    }
    
    
    private func setupLabels() {
        subTotalLbl.text = "$" + String(StripeCart.instance.subtotal/100)
        proccessingFeeLbl.text = "$" + String(StripeCart.instance.proccessingFees/100)
        shippingFeeLbl.text = "$" + String(StripeCart.instance.shippingFees/100)
        TotalLbl.text = "$" + String(StripeCart.instance.total/100)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CatrItem", bundle: nil), forCellReuseIdentifier: "CatrItem")
    }

}

//MARK:- Srtipe payment delegate
extension CheckoutVC: STPPaymentContextDelegate {
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
    }
    
    private func setupStripeConfig() {
        let config = STPPaymentConfiguration.shared
        config.requiredBillingAddressFields = .none
        config.requiredShippingAddressFields = [.postalAddress]
        let customerContext = STPCustomerContext(keyProvider: StripeApi())
        
        paymentContext =  STPPaymentContext(customerContext: customerContext, configuration: config, theme: .defaultTheme)
        paymentContext.paymentAmount = StripeCart.instance.total
        paymentContext.delegate = self
        paymentContext.hostViewController = self

    }
}
