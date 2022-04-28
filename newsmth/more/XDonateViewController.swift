//
//  XDonateViewController.swift
//  newsmth
//
//  Created by Max on 2022/4/27.
//  Copyright © 2022 nju. All rights reserved.
//

import UIKit
import StoreKit

class XDonateViewController: SMViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for tran in transactions {
            switch tran.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(tran)
                self.paySuccess()
                break
            case .restored:
                SKPaymentQueue.default().finishTransaction(tran)
                self.paySuccess()
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(tran)
                print("iap fail")
                break
            default:
                break
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        print("iap products", products)
        if (products.isEmpty) {
            print("not iap products")
            return ;
        }
        self.product = products[0]
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.product.priceLocale
        let price = formatter.string(from: self.product.price)
        
        DispatchQueue.main.async {
            self.payButton.setTitle("支持作者的坚持 \(price!)", for: .normal)
            self.payButton.sizeToFit()
        }
    }
    
    let iapID = "me.maxwin.xsmth.pro"
    var product: SKProduct!
    var payButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()
        let text = NSMutableAttributedString(string: "9年xsmth\n1000+次代码变更\n")
        label.numberOfLines = 0
        label.attributedText = text
        label.sizeToFit()
        self.view.addSubview(label)
        
        let restoreButton = UIButton(type: .system)
        restoreButton.setTitle("恢复购买", for: .normal)
        restoreButton.sizeToFit()
        restoreButton.addTarget(self, action: #selector(onRestoreClick), for: .touchUpInside)
        var frame = restoreButton.frame
        frame.origin.y = label.frame.origin.y + label.frame.size.height
        restoreButton.frame = frame
        self.view.addSubview(restoreButton)
        
        let button = UIButton(type: .system)
        button.setTitle("支持作者的坚持", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(onPayClick), for: .touchUpInside)
        frame = button.frame
        frame.origin.y = restoreButton.frame.origin.y
        frame.origin.x = restoreButton.frame.origin.x + restoreButton.frame.size.width + 10
        button.frame = frame
        self.view.backgroundColor = .red
        self.view.addSubview(button)
        self.payButton = button
        
        SKPaymentQueue.default().add(self)
        let ids = Set<String>.init([self.iapID])
        let request = SKProductsRequest.init(productIdentifiers: ids)
        request.delegate = self
        request.start()
    }
    
    @objc func onPayClick() {
        let payment = SKMutablePayment.init(product: self.product)
        payment.quantity = 1
        SKPaymentQueue.default().add(payment)
    }
    
    @objc func onRestoreClick() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paySuccess() {
        UserDefaults.standard.set(true, forKey: "ispro")
        NotificationCenter.default.post(name:  Notification.Name("iap_update_pro_success"), object: nil)
    }
}
