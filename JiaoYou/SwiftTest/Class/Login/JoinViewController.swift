//
//  JoinViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/15.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import StoreKit
import RJNetworking_Swift
import JMessage

class JoinViewController: RJViewController {

    var receipt: String?
    let productIdentifier = "com.tongyi.taohua.60"
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "确定要离去吗？\n离幸福只差一步了", message: nil, preferredStyle: .alert)
        let lhAction = UIAlertAction.init(title: "确定", style: .default, handler: { [weak self] (action) in
            self?.navigationController?.popViewController(animated: true)
        })
        lhAction.setValue(UIColor.lightGray, forKey: "_titleTextColor")
        alert.addAction(lhAction)
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func joinAction(_ sender: UIButton) {
        guard SKPaymentQueue.canMakePayments() else {
            //用户不允许内购
            return
        }
        showProgressHUD()
        let arr = [productIdentifier]
        let set = Set(arr)
        let request = SKProductsRequest(productIdentifiers: set)
        request.delegate = self
        request.start()
    }
    
    @IBAction func payWhy(_ sender: Any) {
        self.showAlert(title: "纯净私密相亲交友社区\n过滤非诚意用户", message: nil, buttonTitle: "OK")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }

}

extension JoinViewController: SKPaymentTransactionObserver, SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let product = response.products
        guard product.count > 0 else {
            self.hideProgressHUD(message: "订单有误，请稍后再试")
            return
        }
        var requestPorduct: SKProduct?
        for pro in product {
            if pro.productIdentifier == productIdentifier {
                requestPorduct = pro
                break
            }
        }
        if requestPorduct != nil {
            let payment = SKMutablePayment(product: requestPorduct!)
            payment.applicationUsername = "\(CurrentUser.sharedInstance.userId)"
            SKPaymentQueue.default().add(payment)
        } else {
            self.hideProgressHUD(message: "订单有误，请稍后再试")
            return
        }
    }
    
    /// 请求失败
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.hideProgressHUD(message: "订单有误，请稍后再试")
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
                self.hideProgressHUD(message: "交易失败，稍后再试")
            default:
                NSLog("unknow")
            }
        }
    }
    
    
    func completeTransaction(_ transaction: SKPaymentTransaction) {
        if let receiptURL = Bundle.main.appStoreReceiptURL {
            if let receiptData = try? Data(contentsOf: receiptURL) {
                //测试验证地址：https://sandbox.itunes.apple.com/verifyReceipt
                //正式验证地址：https://buy.itunes.apple.com/verifyReceipt
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
                    self.hideProgressHUD(message: "支付失败，稍后再试")
                    SKPaymentQueue.default().finishTransaction(transaction)// 销毁操作
                    return
                }
                RJNetworking.CJNetworking().applePay(1, order: transaction.transactionIdentifier!, receipt: receipt!, test: isTest) { (response) in
                    if response.code == .Success {
                        let userDefault = UserDefaults.standard
                        CurrentUser.sharedInstance.vip = 1
                        userDefault.set(CurrentUser.sharedInstance.userId, forKey: "uid")
                        userDefault.set(CurrentUser.sharedInstance.city_id, forKey: "city_id")
                        userDefault.set(CurrentUser.sharedInstance.vip, forKey: "vip")
                        userDefault.synchronize()
                        DispatchQueue.main.async {
                            self.loginJM()
                        }
                    } else {
                        self.hideProgressHUD(message: response.message)
                    }
                    SKPaymentQueue.default().finishTransaction(transaction)// 销毁操作
                }
            }
        }
    }
    
    func loginJM() {
        let userDefault = UserDefaults.standard
        CurrentUser.sharedInstance.vip = 2
        userDefault.set(CurrentUser.sharedInstance.vip, forKey: "vip")
        userDefault.synchronize()
        if  CurrentUser.sharedInstance.loginJM == false {
            JMSGUser.login(withUsername: CurrentUser.sharedInstance.JMUserName!, password: CurrentUser.sharedInstance.JMUserPwd) { (result, error) in
                if error == nil {
                    CurrentUser.sharedInstance.loginJM = true
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = RJTabBarController()
                    DispatchQueue.global().async {
                        let num = JMSGConversation.getAllUnreadCount().intValue
                        CurrentUser.showMessageBadge(num)
                    }
                    self.hideProgressHUD()
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                    self.hideProgressHUD()
                }
            }
        } else {
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
           appDelegate.window?.rootViewController = RJTabBarController()
           DispatchQueue.global().async {
               let num = JMSGConversation.getAllUnreadCount().intValue
               CurrentUser.showMessageBadge(num)
           }
           self.hideProgressHUD()
        }
    }
}

