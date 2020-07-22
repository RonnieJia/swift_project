//
//  SearchViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/3/20.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {

    var searchTF: UITextField = UITextField()
    
    let foreView: UIView = UIView(frame: CGRect(x: 0, y: kNavigatioBarHeight, width: kScreenWidth, height: kScreenHeight))
    
    var collectionView: UICollectionView!
    
    var dataArr = [Any]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var searchString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createMainView()
    }
    
    func createMainView() {
        view.backgroundColor = .white
        let searchView = UIView(frame: CGRect(x: 0, y: kStatusBarHeight, width: view.width, height: 44))
        view.addSubview(searchView)
        
        searchTF.frame = CGRect(x: 15, y: 7, width: view.width-95, height: 30)
        searchTF.placeholder = "请输入搜索内容"
        let imgView = UIImageView(image: UIImage(named: "screenbar_search"))
        imgView.contentMode = .center
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftView.addSubview(imgView)
        imgView.size(CGSize(width: 30, height: 30))
        searchTF.leftView = leftView
        searchTF.backgroundColor = UIColor.init(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        searchTF.leftViewMode = .always
        searchTF.layer.cornerRadius = 15;
        searchTF.clipsToBounds = true
        searchView.addSubview(searchTF)
        searchTF.clearButtonMode = .whileEditing
        searchTF.returnKeyType = .search
        searchTF.delegate = self
        
        let cancelBtn = UIButton(type: .system)
        cancelBtn.frame = CGRect(x: view.width - 70, y: 7, width: 55, height: 30)
        searchView.addSubview(cancelBtn)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        let wid: CGFloat = (view.width - 60)/4.0
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.itemSize = CGSize(width: wid, height: wid * 1.5+40)
        collectionLayout.minimumLineSpacing = 10.0
        collectionLayout.minimumInteritemSpacing = 10.0
        collectionView = UICollectionView(frame: CGRect(x: 0, y: kNavigatioBarHeight, width: view.width, height: view.height-kNavigatioBarHeight - UITabBar.appearance().size.height), collectionViewLayout: collectionLayout)
        collectionView?.backgroundColor = .white
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
        collectionView?.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView!)
        
        self.view.addSubview(self.foreView)
        self.foreView.isHidden = true
        self.foreView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
    }
    
    @objc func cancelAction() {
        if searchTF.isFirstResponder {
            searchTF.resignFirstResponder()
            self.foreView.isHidden = true
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.dataArr.count > 0 {
            self.foreView.isHidden = false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.count > 0 {
            self.searchString = text
            self.fetchData()
            textField.resignFirstResponder()
            self.foreView.isHidden = true
        } else {
            showMessage(message: "请输入搜索内容")
        }
        return true
    }
    
    func fetchData() {
        showProgressHUD()
        self.dataArr.removeAll()
        self.collectionView.isHidden = false
        /*
        RJAlamofire.sharedInstance.GETDataRequest(with: "xiangjiaosoushenhe/name/\(searchString)", paramters: nil) { (success, message, response) in
            self.collectionView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
            if success {
                self.hideProgressHUD()
                if let list = response?["list"] as? [[String: String]] {
                    if let homeList = HomeList.homeListArr(list: list) {
                        self.dataArr.append(contentsOf: homeList)
                    }
                }
            } else {
                self.hideProgressHUD(message: message)
            }
        }
 */
    }

}



extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SearchCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SearchCollectionViewCell
        if let info = dataArr[indexPath.row] as? HomeList {
            cell.titleLabel.text = info.title
            cell.imgView.kf.setImage(with: URL(string: info.img!)!)
        }

        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
