//
//  DynamicViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/3.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift
import MJRefresh

class DynamicViewController: RJViewController {

    var segment: UISegmentedControl?
    
    var scrollView: UIScrollView?
    
    var loadFollow = false
    
    var followPage = 1
    
    var dataArr = [SocietyModel]()
    var followArr = [SocietyModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        createMainView()
        fetchList()
    }
    
    private func createMainView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth+10, height: kScreenHeight - kNavigatioBarHeight - safeBottom(49)))
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
            tableView.tag = 901 + index
            scrollView?.addSubview(tableView)
            
            tableView.mj_header = MJRefreshStateHeader(refreshingBlock: { [weak self] in
                if index == 0 {
                    self?.page = 1
                    self?.fetchList(1)
                } else {
                    self?.followPage = 1
                    self?.fetchList(2)
                }
            })
            
            tableView.mj_footer = MJRefreshAutoStateFooter(refreshingBlock: { [weak self] in
                if index == 0 {
                    self?.page += 1
                    self?.fetchList(1)
                } else {
                    self?.followPage += 1
                    self?.fetchList(2)
                }
            })
        }
        
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "add001_1")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(publishDynamic))
        segment = UISegmentedControl(items: ["推荐", "关注"])
        segment?.width(120)
        navigationItem.titleView = segment!
        if #available(iOS 13.0, *) {
            segment?.backgroundColor = .black
            segment?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: .selected)
            segment?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        } else {
            segment?.tintColor = .black
            segment?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
            segment?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: .normal)
        }
        segment?.selectedSegmentIndex = 0
        segment?.addTarget(self, action: #selector(changeTitleItem(segment:)), for: .valueChanged)
    }
    
    @objc func changeTitleItem(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 1 && CurrentUser.isVisitor() {
            segment.selectedSegmentIndex = 0
            showLoginAlert()
            return
        }
        if segment.selectedSegmentIndex == 1 && !self.loadFollow {
            self.loadFollow = true
            self.fetchList(2, page: self.followPage)
        }
        self.scrollView?.setContentOffset(CGPoint(x: scrollView!.width * CGFloat(segment.selectedSegmentIndex), y: 0), animated: true)
    }
    
    @objc func publishDynamic() {
        if CurrentUser.isVisitor() {
            showLoginAlert()
        } else {
            if CurrentUser.sharedInstance.vip <= 1 {
                VipView.show {
                    self.showVipView()
                }
            } else {
                self.navigationController?.pushViewController(IssueViewController(), animated: true)
            }
        }
    }
    func showVipView() {
        let story = UIStoryboard(name: "Mine", bundle: nil)
        let vip = story.instantiateViewController(withIdentifier: "vipcenter")
        self.navigationController?.pushViewController(vip, animated: true)
    }
}

extension DynamicViewController {
    private func fetchList (_ type: Int = 1, page: Int = 1) {
        showProgressHUD()
        RJNetworking.CJNetworking().societyList(type, page: page) { (response) in
            let tag = 900 + type
            guard let tableView = self.scrollView?.viewWithTag(tag) as? UITableView else {
                return
            }
            tableView.mj_header?.endRefreshing()
            if response.code == .Success {
                let arr = SocietyModel.listArr(list: response.response)
                if type == 1 {
                    if page == 1 {
                        self.dataArr.removeAll()
                    }
                    self.dataArr += arr
                    
                } else {
                    if page == 1 {
                        self.followArr.removeAll()
                    }
                    self.followArr += arr
                }
                if arr.count < 10 {
                    tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    tableView.mj_footer?.endRefreshing()
                }
                tableView.reloadData()
                self.hideProgressHUD()
            } else {
                if type == 1 {// 加载更多出错，回滚
                    self.page -= 1
                } else {
                    self.followPage -= 1
                }
                tableView.mj_footer?.endRefreshing()
                self.hideProgressHUD(message: response.message)
            }
        }
    }
}

/// UITableViewDelegate DateSource
extension DynamicViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if CurrentUser.isVisitor() {
            self.showLoginAlert()
            return
        }
        var model: SocietyModel
        if tableView.tag == 901 {
            model = self.dataArr[indexPath.row]
        } else {
           model = self.followArr[indexPath.row]
        }
        let detail = DynamicDetailViewController(society: model)
        detail.likeBlock = { (like) in
            if tableView.tag == 901 {
                var model = self.dataArr[indexPath.row]
                model.like = like
                if like == 1 {
                    model.like_num += 1
                } else {
                     model.like_num -= 1
                }
                self.dataArr[indexPath.row] = model
            } else {
                var model = self.followArr[indexPath.row]
                model.like = like
                if like == 1 {
                    model.like_num += 1
                } else {
                     model.like_num -= 1
                }
                self.dataArr[indexPath.row] = model
            }
            tableView.reloadData()
        }
        detail.followBlock = { (follow) in
            if tableView.tag == 901 {
                var model = self.dataArr[indexPath.row]
                model.follow = follow
                self.dataArr[indexPath.row] = model
            } else {
                if follow != 1 {
                    self.followArr.remove(at: indexPath.row)
                } else {
                    tableView.mj_header?.beginRefreshing()
                }
            }
            tableView.reloadData()
        }
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 901 {
            return dataArr.count
        }
        return followArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = RecommendTableViewCell.cell(with: tableView)
        if tableView.tag == 901 {
            cell.model = self.dataArr[indexPath.row]
        } else {
           cell.model = self.followArr[indexPath.row]
        }
        cell.jubaoBlock = { [unowned self] (model: SocietyModel) in
            self.jubaoSoc(model)
        }
        cell.followBlock = { [unowned self] (model: SocietyModel) in
            self.followAction(tableView, index: indexPath.row)
        }
        cell.likeBlock = { [unowned self] (model: SocietyModel) in
            self.likeAction(tableView, index: indexPath.row)
            
        }
        return cell
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
    
    private func likeAction(_ tableView: UITableView, index: Int) {
        if CurrentUser.isVisitor() {
            showLoginAlert()
            return
        }
        showProgressHUD()
        var soc = self.dataArr[index]
        RJNetworking.CJNetworking().likeShow(soc.show_id) { (response) in
            if response.code == .Success {
                if let cancel = response.message?.contains("取消"), cancel {
                    soc.like_num -= 1
                    soc.like = 2
                } else {
                    soc.like_num += 1
                    soc.like = 1
                }
                self.dataArr[index] = soc
                tableView.reloadData()
            }
            self.hideProgressHUD(message: response.message)
        }
    }
    
    private func followAction(_ tableView: UITableView, index: Int) {
        if tableView.tag == 901 {
            if index >= self.dataArr.count {
                return
            }
            
            showProgressHUD()
            var soc = self.dataArr[index]
            if soc.user_id == CurrentUser.sharedInstance.userId {
                hideProgressHUD(message: "不能关注自己~")
                return
            }
            RJNetworking.CJNetworking().followUser(soc.user_id) { (response) in
                if response.code == .Success {
                    if let cancel = response.message?.contains("取关"), cancel {
                        soc.follow = 2
                    } else {
                        soc.follow = 1
                    }
                    self.dataArr[index] = soc
                    tableView.reloadData()
                }
                self.hideProgressHUD(message: response.message)
                
            }
        } else {
            if index >= self.followArr.count {
                return
            }
            showProgressHUD()
            var soc = self.followArr[index]
            if soc.user_id == CurrentUser.sharedInstance.userId {
                hideProgressHUD(message: "不能关注自己~")
                return
            }
            RJNetworking.CJNetworking().followUser(soc.user_id) { (response) in
                if response.code == .Success {
                    if let cancel = response.message?.contains("取关"), cancel {
                        soc.follow = 2
                        self.followArr.remove(at: index)
                    } else {
                        soc.follow = 1
                        self.followArr[index] = soc
                    }
                    tableView.reloadData()
                }
                self.hideProgressHUD(message: response.message)
                
            }
        }
        
    }
    
    private func jubaoSoc(_ model: SocietyModel) {
        if CurrentUser.isVisitor() {
            showLoginAlert()
            return
        }
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "举报", style: .destructive, handler: { [weak self] (action) in
            let report = ReportViewController()
            report.uid = model.user_id
            self?.navigationController?.pushViewController(report, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
}



