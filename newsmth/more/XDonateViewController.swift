//
//  XDonateViewController.swift
//  newsmth
//
//  Created by Max on 2022/4/27.
//  Copyright © 2022 nju. All rights reserved.
//

import UIKit
import StoreKit
import Alamofire


class XDonateViewController: SMViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    let keyOfDonate = "ns_key_donate_config"
    let liteProID = "me.maxwin.xsmth.litepro"
    let proID = "me.maxwin.xsmth.pro"
    var products: [SKProduct] = []
    var payButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SKPaymentQueue.default().add(self)
        let ids = Set<String>.init([self.liteProID, self.proID])
        let request = SKProductsRequest.init(productIdentifiers: ids)
        request.delegate = self
        request.start()
        
        self.loadConfig()
    }
    
    func paySuccess() {
        UserDefaults.standard.set(true, forKey: "ispro")
        NotificationCenter.default.post(name:  Notification.Name("iap_update_pro_success"), object: nil)
    }
    
    func loadConfig() {
        if (UserDefaults.standard.integer(forKey: keyOfDonate) != 1) {
            SMAF.request("https://maxwin-z.github.io/xsmth/donate.json").response { rsp in
                do {
                    if let data = try rsp.result.get() {
                        if let flag = String(data: data, encoding: .utf8) {
                            debugPrint("donate", flag)
                            if (flag.range(of: "1") != nil) {
                                UserDefaults.standard.set(1, forKey: self.keyOfDonate)
                                self.setupViews()
                            }
                        }
                    }
                } catch {
                    
                }
            }
        }
    }
    
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
        self.products = products;
        
        DispatchQueue.main.async {
            self.setupViews()
        }
    }
    
    func setupViews() {
        // clear
        for v in self.view.subviews {
            v.removeFromSuperview()
        }
        
        let donate = UserDefaults.standard.integer(forKey: self.keyOfDonate) == 1
        
        let label = UILabel()
        let text = NSMutableAttributedString(string: donate ? "9年xsmth\n1000+次代码变更\n作者的坚持，希望能得到大家的支持😁" : "Minecraft Python编程")
        if (donate) {
            let font = UIFont.systemFont(ofSize: 30)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.systemBlue,
            ]
            text.addAttributes(attributes, range: NSRange(location: 0, length: 2))
            text.addAttributes(attributes, range: NSRange(location: 8, length: 5))
        } else {
            let font = UIFont.systemFont(ofSize: 30)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.red,
            ]
            text.addAttributes(attributes, range: NSRange(location: 0, length: text.length))
        }
        label.numberOfLines = 0
        label.attributedText = text
        label.sizeToFit()
        self.view.addSubview(label)

        let restoreButton = UIButton(type: .custom)
        restoreButton.backgroundColor = UIColor(red: 24 / 255, green: 144 / 255, blue: 1, alpha: 1)
        restoreButton.setTitle("恢复购买", for: .normal)
        restoreButton.sizeToFit()
        restoreButton.addTarget(self, action: #selector(onRestoreClick), for: .touchUpInside)
        var frame = restoreButton.frame
        frame.origin.y = label.frame.origin.y + label.frame.size.height + 10
        frame.size.width += 10
        restoreButton.frame = frame
        frame.origin.x += 10
        self.view.addSubview(restoreButton)
        
        let donateIcons = ["🧋", "🥤"]
        for i in 0...(self.products.count - 1) {
            let product = self.products[i]
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            let price = formatter.string(from: product.price)
            let title = (donate ? donateIcons[i] : product.localizedTitle) + (price ?? "")
            
            let button = UIButton(type: .custom)
            button.backgroundColor = UIColor(red: 24 / 255, green: 144 / 255, blue: 1, alpha: 1)
            button.setTitle(title, for: .normal)
            button.sizeToFit()
            button.tag = i
            button.addTarget(self, action: #selector(onPayClick(_:)), for: .touchUpInside)
            var btnFrame = button.frame
            btnFrame.origin.x = frame.origin.x + frame.size.width
            btnFrame.origin.y = frame.origin.y
            btnFrame.size.width += 20
            button.frame = btnFrame
            if (donate) {
                frame = btnFrame
                frame.origin.x += 10
            } else {
                frame = CGRect(x: 0, y: frame.origin.y + frame.size.height + 10, width: 0, height: 0)
            }
            self.view.addSubview(button)
        }
    }
    
    @objc func onPayClick(_ sender: UIButton) {
        let product = self.products[sender.tag]
        let payment = SKMutablePayment.init(product: product)
        payment.quantity = 1
        SKPaymentQueue.default().add(payment)
    }
    
    @objc func onRestoreClick() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}
