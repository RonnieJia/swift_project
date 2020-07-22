//
//  LikeListViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/26.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift

class LikeListViewController: RJViewController {
    
    var dataArr: [VistorModel] = []
    var dataArr2: [VistorModel] = []
    
    var segment: UISegmentedControl?
    
    var scrollView: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _setupNavigationBar()
        _createMainView()
        
        fetchList(1)
        fetchList(2)
    }
    
    private func _setupNavigationBar() {
        segment = UISegmentedControl(items: ["关注", "关注者"])
        segment?.width(120)
        if #available(iOS 13.0, *) {
            segment?.backgroundColor = .black
            segment?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: .selected)
            segment?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        } else {
            segment?.tintColor = .black
            segment?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
            segment?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: .normal)
        }
        navigationItem.titleView = segment!
        segment?.selectedSegmentIndex = 0
        segment?.addTarget(self, action: #selector(changeTitleItem(segment:)), for: .valueChanged)
    }
    
    private func _createMainView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth+10, height: kScreenHeight - kNavigatioBarHeight))
        view.addSubview(scrollView!)
        scrollView?.contentSize = CGSize(width: kScreenWidth * 2 + 20, height: scrollView!.height - 1)
        scrollView?.isPagingEnabled = true
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.bounces = false
        scrollView?.delegate = self
        scrollView?.tag = 10
        
        for index in 0 ..< 2 {
            let tableView = UITableView(frame: CGRect(x: CGFloat(index) * (kScreenWidth + 10), y: 0, width: kScreenWidth, height: scrollView!.height))
            tableView.backgroundColor = viewBackgroundColor
            tableView.separatorStyle = .none
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tag = 101 + index
            tableView.rowHeight = 80
            scrollView?.addSubview(tableView)
            tableView.register(UINib(nibName: "VistorTableViewCell", bundle: nil), forCellReuseIdentifier: "vistor")
        }
    }
    
    @objc private func changeTitleItem(segment: UISegmentedControl) {
        self.scrollView?.setContentOffset(CGPoint(x: scrollView!.width * CGFloat(segment.selectedSegmentIndex), y: 0), animated: true)
    }
    
    func fetchList(_ type: Int)  {
        showProgressHUD()
        let tableview = self.scrollView?.viewWithTag(100 + type) as! UITableView
        RJNetworking.CJNetworking().followList(type) { (response) in
            if response.code == .Success {
                let arr = VistorModel.listArr(list: response.response?["list"])
                if type == 1 {
                    self.dataArr += arr
                } else {
                    self.dataArr2 += arr
                }
                if arr.count > 0 {
                    if CurrentUser.sharedInstance.vip > 1 {
                        tableview.tableFooterView = UIView()
                    } else {
                        tableview.tableFooterView = self.vipFooterView()
                    }
                } else {
                    tableview.tableFooterView = self.nullView()
                }
                tableview.reloadData()
                self.hideProgressHUD()
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }

    func vipFooterView() -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 100))
        let moreBtn = RJTextButton(frame: CGRect(x: kScreenWidth / 2.0 - 110, y: 15, width: 220, height: 48), text: "升级会员查看更多关注")
        moreBtn.addTarget(self, action: #selector(vipAction), for: .touchUpInside)
        footer.addSubview(moreBtn)
        moreBtn.cornerRadius = 24
        moreBtn.borderColor = .darkGray
        moreBtn.borderWidth = 1
        return footer
    }
    
    @objc func vipAction() {
        let story = UIStoryboard(name: "Mine", bundle: nil)
        let vip = story.instantiateViewController(withIdentifier: "vipcenter")
        self.navigationController?.pushViewController(vip, animated: true)
    }
    
    func nullView() -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 100))
        let label = RJLabel(frame: CGRect(x: 10, y: 20, width: kScreenWidth - 20, height: 20), textAlignment: .center, text: "暂无关注")
        footer.addSubview(label)
        return footer
    }
    
}

/// UITableViewDelegate DateSource
extension LikeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 101 {
            if CurrentUser.sharedInstance.vip > 1 {
                return dataArr.count
            }
            return dataArr.count > 1 ? 1 : dataArr.count
        }
        if CurrentUser.sharedInstance.vip > 1 {
            return dataArr2.count
        }
        return dataArr2.count > 1 ? 1 : dataArr2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "vistor", for: indexPath) as! VistorTableViewCell
        if tableView.tag == 101 {
            cell.model = self.dataArr[indexPath.row]
        } else {
            cell.model = self.dataArr2[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && scrollView.tag == 10 {
            scrollViewDidEndMoving(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.tag == 10 {
            scrollViewDidEndMoving(scrollView)
        }
    }
    
    func scrollViewDidEndMoving(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < kScreenWidth / 2.0 + 5 {
            segment?.selectedSegmentIndex = 0
        } else {
            segment?.selectedSegmentIndex = 1
        }
    }
}

