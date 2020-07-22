//
//  MineViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/3/11.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import Masonry
import RJUtils_Swift
import RJNetworking_Swift
import JXPhotoBrowser
import MJRefresh
import StoreKit

extension UIButton {
    func style() {
        let color = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1.0)
        self.backgroundColor = color
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 8
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        let layer = self.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 0.3
        
        let shadowWidth = layer.bounds.width * 0.9
        let shadowRect = CGRect(x: 0 + (layer.bounds.width - shadowWidth) / 2.0, y: 0, width: shadowWidth, height: layer.bounds.height)
        layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
        layer.zPosition = 2
    }
}


class MineViewController: RJViewController {
    
    

    var receipt: String?
    var type: Int?
    var productId: String?
    
    var dataArray: [SocietyModel] = []
    var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _createCollectionView()
        fetchUserInfo()
        fetchShows()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchUserInfo()
    }
    
    private func _createCollectionView() {
        view.addSubview(tableView)
        tableView.register(UINib(nibName: "MineTableViewCell", bundle: nil), forCellReuseIdentifier: "mine")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets.zero)
        }
        adjustsScrollViewInsets(tableView)
        tableView.tableHeaderView = header
        
        tableView.mj_header = MJRefreshStateHeader.init(refreshingBlock: {
            self.page = 1
            self.fetchShows()
        })
        
        tableView.mj_footer = MJRefreshAutoStateFooter.init(refreshingBlock: {
            self.page += 1
            self.fetchShows()
        });
        
    }
    
    func fetchShows() {
        showProgressHUD()
        RJNetworking.CJNetworking().userShows(CurrentUser.sharedInstance.userId, page: self.page) { (response) in
            self.tableView.mj_header?.endRefreshing()
            if response.code == .Success {
                let arr = SocietyModel.listArr(list: response.response)
                if self.page == 1 {
                    self.dataArray.removeAll()
                }
                self.dataArray += arr
                if arr.count < 10 {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer?.endRefreshing()
                }
                self.tableView.reloadData()
                self.hideProgressHUD()
            } else {
                if self.page > 1 {// 加载更多出错，回滚
                    self.tableView.mj_footer?.endRefreshing()
                    self.page -= 1
                }
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    private func fetchUserInfo() {
        RJNetworking.CJNetworking().userInfo { (response) in
            if response.code == .Success{
                CurrentUser.sharedInstance.userInfo(response.response?["info"])
                self.header.displayInfo()
            }
        }
        
        RJNetworking.CJNetworking().fetchAuthInfo { (response) in
            if response.code == .Success {
                if let cardState = response.response?["video"]["video_state"].intValue {
                    self.header.authBtn.isSelected = cardState == 3
                }
            }
        }
    }
    
    lazy var header: MineHeaderView = {
        let h = MineHeaderView()
        h.itemBlock = { (index) in
            let story = UIStoryboard(name: "Mine", bundle: nil)
            if index == 100 {
                let edit = story.instantiateViewController(withIdentifier: "editinfo")
                self.navigationController?.pushViewController(edit, animated: true)
            } else if index == 102 {
                if CurrentUser.sharedInstance.vip > 1 {
                    self.showMessage(message: "您已是尊贵的会员")
                    return
                }
                VipMoneyView.show { (type, product) in
                    self.vipCZ(type, product: product)
                }
//                let vip = story.instantiateViewController(withIdentifier: "vipcenter")
//                self.navigationController?.pushViewController(vip, animated: true)
            } else if index == 101 {

                let set = story.instantiateViewController(withIdentifier: "setting")
                self.navigationController?.pushViewController(set, animated: true)
            } else if index == 200 {
                let auth = story.instantiateViewController(withIdentifier: "authCentenr")
                self.navigationController?.pushViewController(auth, animated: true)
            }
        }
        return h
    }()
    
    
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

extension MineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mine", for: indexPath) as! MineTableViewCell
        cell.model = dataArray[indexPath.row]
        cell.niceBlock = {
            self.likeAction(tableView, index: indexPath.row)
        }
        return cell
    }
    
    private func likeAction(_ tableView: UITableView, index: Int) {
        if CurrentUser.isVisitor() {
            showLoginAlert()
            return
        }
        showProgressHUD()
        var soc = dataArray[index]
        RJNetworking.CJNetworking().likeShow(soc.show_id) { (response) in
            if response.code == .Success {
                if let cancel = response.message?.contains("取消"), cancel {
                    soc.like_num -= 1
                    soc.like = 2
                } else {
                    soc.like_num += 1
                    soc.like = 1
                }
                self.dataArray[index] = soc
                tableView.reloadData()
            }
            self.hideProgressHUD(message: response.message)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model = self.dataArray[indexPath.row]
        model.nickname = CurrentUser.sharedInstance.nickname ?? " "
        model.age = CurrentUser.sharedInstance.age
        model.constellation = CurrentUser.sharedInstance.constellation ?? " "
        let detail = DynamicDetailViewController(society: model)
        self.navigationController?.pushViewController(detail, animated: true)
    }
}

extension MineViewController {
    
    @objc func showImg(_ index: Int = 0) {
        guard index < dataArray.count else {
            return
        }
        
        let browser = JXPhotoBrowser()
        browser.numberOfItems = {
            return self.dataArray.count
        }
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            browserCell?.imageView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(self.dataArray[context.index])"), placeholder: UIImage(named: ""))
        }
        let pageIndicator = JXPhotoBrowserNumberPageIndicator(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        browser.pageIndicator = pageIndicator
        browser.view.addSubview(pageIndicator)
        browser.pageIndex = index
        browser.reloadData()
        browser.show()
    }
}

extension MineViewController: SKPaymentTransactionObserver, SKProductsRequestDelegate {
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


