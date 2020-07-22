//
//  VipCenterViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/30.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import StoreKit
import RJNetworking_Swift

class VipCenterViewController: RJViewController {

    var receipt: String?
    var type: Int?
    var productId: String?
    
    @IBOutlet weak var vipLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "VIP中心"
        if CurrentUser.sharedInstance.avatarUrl != nil {
            self.avatarImgView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(CurrentUser.sharedInstance.avatarUrl!)"), placeholder: UIImage(named: "face002"))
        } else {
            self.avatarImgView.image = UIImage(named: "face002")
        }
        self.nameLabel.text = CurrentUser.sharedInstance.nickname
        if CurrentUser.sharedInstance.vip > 1 {
            self.vipLabel.text = "已激活会员"
        }
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    @IBAction func vipAction(_ sender: UIButton) {
        VipMoneyView.show { (type, product) in
            self.vipCZ(type, product: product)
        }
    }
    
    private func vipCZ(_ type: Int, product: String) {
        guard SKPaymentQueue.canMakePayments() else {
            //用户不允许内购
            return
        }
        self.productId = product
        self.type = type
        self.navigationController?.showProgressHUD()
        let arr = [product]
        let set = Set(arr)
        let request = SKProductsRequest(productIdentifiers: set)
        request.delegate = self
        request.start()
    }

}


extension VipCenterViewController: SKPaymentTransactionObserver, SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let product = response.products
        guard product.count > 0 else {
            self.navigationController?.hideProgressHUD(message: "订单有误，请稍后再试")
            return
        }
        var requestPorduct: SKProduct?
        for pro in product {
            if pro.productIdentifier == self.productId! {
                requestPorduct = pro
                break
            }
        }
        if requestPorduct != nil {
            let payment = SKMutablePayment(product: requestPorduct!)
            payment.applicationUsername = "\(CurrentUser.sharedInstance.userId)"
            SKPaymentQueue.default().add(payment)
        } else {
            self.navigationController?.hideProgressHUD(message: "订单有误，请稍后再试")
            return
        }
    }
    
    /// 请求失败
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.navigationController?.hideProgressHUD(message: "订单有误，请稍后再试")
    }
    
    /// 请求完成
    func requestDidFinish(_ request: SKRequest) {
        
    }
    
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for tran in transactions {
            switch tran.transactionState {
            case .purchased:
                completeTransaction(tran)
                NSLog("交易完成")
            case .purchasing:
                NSLog("商品添加进列表")
            case .restored:
                NSLog("已经购买过商品")
            case .failed:
                SKPaymentQueue.default().finishTransaction(tran)// 销毁操作
                self.navigationController?.hideProgressHUD(message: "交易失败，稍后再试")
            default:
                NSLog("unknow")
            }
        }
    }
    
    
    func completeTransaction(_ transaction: SKPaymentTransaction) {
        if let receiptURL = Bundle.main.appStoreReceiptURL {
            if let receiptData = try? Data(contentsOf: receiptURL) {
                var isTest = false
                var verPath = "https://buy.itunes.apple.com/verifyReceipt"
                if receiptURL.absoluteString.contains("sandboxReceipt") {//
                    isTest = true
                    verPath = "https://sandbox.itunes.apple.com/verifyReceipt"
                }
                guard let url = URL(string: verPath) else { return }
                var urlRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 15.0)
                urlRequest.httpMethod = "POST"
                let encodeStr = receiptData.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithLineFeed)
                receipt = encodeStr
                let payload = "{\"receipt-data\" : \"\(encodeStr)\"}"
                let payloadData = payload.data(using: String.Encoding.utf8)
                urlRequest.httpBody = payloadData
                guard let _ = try? NSURLConnection.sendSynchronousRequest(urlRequest, returning: nil) else {
                    self.navigationController?.hideProgressHUD(message: "支付失败，稍后再试")
                    SKPaymentQueue.default().finishTransaction(transaction)// 销毁操作
                    return
                }
                var payType = 2
                if self.type == 1 {
                    payType = 4
                } else if self.type == 2{
                    payType = 3
                }
                RJNetworking.CJNetworking().applePay(payType, order: transaction.transactionIdentifier!, receipt: receipt!, test: isTest) { (response) in
                    if response.code == .Success {
                        let userDefault = UserDefaults.standard
                        CurrentUser.sharedInstance.vip = 2
                        userDefault.set(CurrentUser.sharedInstance.vip, forKey: "vip")
                        userDefault.synchronize()
                        self.vipLabel.text = "已激活会员"
                        self.navigationController?.hideProgressHUD()
                    } else {
                        self.navigationController?.hideProgressHUD(message: response.message)
                    }
                    SKPaymentQueue.default().finishTransaction(transaction)// 销毁操作
                }
                
                
            }
        }
    }
}

