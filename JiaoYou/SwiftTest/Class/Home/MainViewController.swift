//
//  MainViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/3/18.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift
import MJRefresh
import Kingfisher
import JMButton
import JMessage
import StoreKit

class MainViewController: RJViewController {
    
    var receipt: String?
    var type: Int?
    var productId: String?
    
    lazy var sortVC: ScreenViewController = {
        let sort = ScreenViewController()
        sort.sortBlock = {
            self.collectionView.mj_header?.beginRefreshing()
        }
        return sort
    }()
    
    var topView: UIView?
    
    var dataArray: [HomeModel] = []
    
    var vistorFirst = true
    
    @objc private func blackUser() {
        collectionView.mj_header?.beginRefreshing()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        SKPaymentQueue.default().remove(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "首页"
        
        NotificationCenter.default.addObserver(self, selector: #selector(blackUser), name: Notification.Name.init(rawValue: "blackUser"), object: nil)
        createNavRightBtn()
        
        topView = UIView()
        view.addSubview(topView!)
        topView?.backgroundColor = RGBAColor(34, 34, 34, 1)
        topView?.mas_makeConstraints { make in
            make?.top.and().left().and().right().mas_equalTo()(0)
            make?.height.mas_equalTo()(36)//36
        }
        let closeBtn = RJImageButton(image: UIImage(named: "close002"))
        topView?.addSubview(closeBtn)
        closeBtn.mas_makeConstraints { (make) in
            make?.top.and().bottom().mas_equalTo()(0)
            make?.right.mas_equalTo()(-10)
            make?.width.mas_equalTo()(30)
        }
        closeBtn.addTarget(self, action: #selector(closeNotiView), for: .touchUpInside)
        let notiBtn = RJTextButton( font: kDetailFont, textColor: .white, backgroundColor: RGBAColor(34, 34, 34, 1), text: "温馨提示：请阅读桃花婚姻介绍所App使用注意事项")
        
        notiBtn.contentHorizontalAlignment = .left
        notiBtn.setImage(UIImage(named: "voice001"), for: .normal)
        topView?.addSubview(notiBtn)
        notiBtn.mas_makeConstraints { (make) in
            make?.left.and()?.top()?.and()?.bottom()?.mas_equalTo()(0)
            make?.right.equalTo()(closeBtn.mas_left)?.offset()(-10)
        }
        notiBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        notiBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        notiBtn.addTarget(self, action: #selector(agreementPush), for: .touchUpInside)
        
        
        view.addSubview(collectionView)
        collectionView.mas_makeConstraints({ (make) in
            make?.left.and()?.right()?.and()?.bottom()?.mas_equalTo()(0)
            make?.top.equalTo()(topView?.mas_bottom)
        })
        
        collectionView.mj_header = MJRefreshStateHeader(refreshingBlock: { [weak self] in
            self?.page = 1
            self?.fetchData()
        })
        
        collectionView.mj_footer = MJRefreshAutoStateFooter(refreshingBlock: {[weak self] in
            self?.page += 1
            self?.fetchData()
        })
        
        collectionView.mj_header?.beginRefreshing()
        fetchUserInfo()
        SKPaymentQueue.default().add(self)
    }
    
    private func fetchUserInfo() {
        guard !CurrentUser.isVisitor() else {
            return
        }
        RJNetworking.CJNetworking().userInfo { (response) in
            if response.code == .Success {
                CurrentUser.sharedInstance.userInfo(response.response?["info"])
            }
        }
    }
    
    @objc func agreementPush() {
        let agree = HelpGuideViewController()
        agree.type = 3
        self.navigationController?.pushViewController(agree, animated: true)
    }
    
    @objc func closeNotiView() {
        topView?.mas_updateConstraints({ (make) in
            make?.height.mas_equalTo()(0)
        })
    }
    
    fileprivate func createNavRightBtn() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "screen001")!.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(pushToScreen))
    }
    
    @objc func pushToScreen() {
        if CurrentUser.isVisitor() {
            self.showLoginAlert()
            return
        }
        self.navigationController?.pushViewController(self.sortVC, animated: true)
    }
    
    lazy var collectionView:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 30, right: 5)
        let wid = (kScreenWidth - 18) / 2.0
        flowLayout.itemSize = CGSize(width: wid, height: wid + 30)
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: "MainCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "maincell")
        return collectionView
    }()
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "maincell", for: indexPath) as! MainCollectionViewCell
        cell.clickBlock = { [weak self] (hId, type) in
            if CurrentUser.isVisitor() {// 游客模式
                self?.showLoginAlert()
            } else {
                if type == 1 {// 聊天
                    if let model = self?.dataArray[indexPath.row] {
                        self?.chat(with: model)
                    }
                } else if (type == 2) {// 关注
                    self?.follow(indexPath.row)
                }
            }
        }
        cell.model = self.dataArray[indexPath.row]
        return cell
    }
}

extension MainViewController {
    func fetchData() {
        showProgressHUD()
        RJNetworking.CJNetworking().homeList(self.page, heightStart: self.sortVC.heightStart, heightEnd: self.sortVC.heightEnd, ageStart: self.sortVC.ageStart, ageEnd: self.sortVC.ageEnd, city: self.sortVC.city, star: self.sortVC.starStr, state: self.sortVC.state, video: self.sortVC.video) { (response) in
            self.collectionView.mj_header?.endRefreshing()
            if response.code == .Success {
                if self.page == 1 {
                    self.dataArray.removeAll()
                }
                if let arr: [HomeModel] = HomeModel.homeListArr(list: response.response) {
                    self.dataArray += arr
                    self.collectionView.reloadData()
                    if arr.count < 10 {
                        self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                    } else {
                        self.collectionView.mj_footer?.endRefreshing()
                    }
                } else {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                }
                self.hideProgressHUD()
            } else {
                self.collectionView.mj_footer?.endRefreshing()
                if self.page > 1 {// 加载更多出错，回滚
                    self.page -= 1
                }
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         let detail = DetailViewController()
         detail.homeIndex = indexPath.item
         detail.likeBlock = { [unowned self] (index, follow) in
             if index < self.dataArray.count {
                 var user = self.dataArray[index]
                 user.follow = follow
                 self.dataArray[index] = user
                 self.tableView.reloadData()
             }
         }
         detail.user = self.dataArray[indexPath.row]
         self.navigationController?.pushViewController(detail, animated: true)
    }
    
    private func showVipView() {
        let story = UIStoryboard(name: "Mine", bundle: nil)
        let vip = story.instantiateViewController(withIdentifier: "vipcenter")
        self.navigationController?.pushViewController(vip, animated: true)
    }
    
    private func chat(with user: HomeModel) {
        guard VipManager.shared.homeCanChat(user.user_id!) else {
            VipMoneyView.show { (type, product) in
                self.vipCZ(type, product: product)
            }
            return
        }
        
        JMSGConversation.createSingleConversation(withUsername: user.jmuserName) { (result, error) in
            if let conversion = result as? JMSGConversation {
                let chatVC = ChatViewController(conversation: conversion)
                self.navigationController?.pushViewController(chatVC, animated: true)
            } else {
                self.showMessage(message: "发生错误，稍后再试")
            }
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
    
    
    private func follow(_ index: NSInteger) {
        if index < self.dataArray.count {
            var user = self.dataArray[index]
            
            if user.user_id! == CurrentUser.sharedInstance.userId {
                showMessage(message: "不能关注自己~")
                return
            }
            showProgressHUD()
            RJNetworking.CJNetworking().followUser(user.user_id!) { (response) in
                if response.code == .Success {
                    if let cancel = response.message?.contains("取关"), cancel {
                        user.follow = 2
                    } else {
                        user.follow = 1
                    }
                    self.dataArray[index] = user
                    self.collectionView.reloadData()
                }
                self.hideProgressHUD(message: response.message)
                
            }
        }
    }
    
    
}


extension MainViewController: SKPaymentTransactionObserver, SKProductsRequestDelegate {
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


