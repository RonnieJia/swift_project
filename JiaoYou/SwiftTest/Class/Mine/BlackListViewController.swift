//
//  BlackListViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/23.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import JMessage
import RJNetworking_Swift

class BlackListViewController: RJViewController {
    
    @IBOutlet weak var blackTableView: UITableView!
    
    var dataArr: [BlackModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetcBlackList()
        
    }
    
    private func fetcBlackList() {
        showProgressHUD()
        RJNetworking.CJNetworking().blackList { (response) in
            if response.code == .Success {
                self.dataArr.removeAll()
                let arr = BlackModel.listArr(list: response.response)
                self.dataArr = arr
                self.blackTableView.reloadData()
                self.hideProgressHUD()
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }

}

extension BlackListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blacklist", for: indexPath) as! BlackListTableViewCell
        cell.model = dataArr[indexPath.row]
        cell.removeBlacklist = { [unowned self] in
            let alert = UIAlertController(title: nil, message: "确定恢复该用户吗", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default) { (action) in
                self.removeFromBlackList(indexPath.row)
            })
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        return cell
    }
    
    func removeFromBlackList(_ index: Int) {
        showProgressHUD()
        let model = self.dataArr[index]
        RJNetworking.CJNetworking().blackUser(model.fuser_id) { (response) in
            if response.code == .Success {
                
            } else {
                if response.message?.contains("取消") == true {
                    self.dataArr.remove(at: index)
                    self.blackTableView.reloadData()
                    CurrentUser.blackUser(model.jmUserName, dele: true)
                }
            }
            self.hideProgressHUD(message: response.message)
        }
    }
    
    
}


