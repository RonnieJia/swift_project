//
//  AuthListViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/30.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift

class AuthListViewController: RJViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var listView: UITableView!
    var stateArr = [1, 1]
    var videoPath: String?
    var fImgPath: String?
    var bImgPath: String?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "authcell", for: indexPath)
        let titleL = cell.contentView.viewWithTag(100) as! UILabel
        titleL.text = "视频认证"//indexPath.row == 0 ? "身份认证" : "视频认证"
        
        let state = stateArr[indexPath.row]
        var stateStr = "未认证"
        if state == 2 {
            stateStr = "审核中"
        } else if state == 3 {
            stateStr = "已认证"
        }
        let sateLabel = cell.contentView.viewWithTag(101) as! UILabel
        sateLabel.text = stateStr
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let state = stateArr[indexPath.row]
        if indexPath.row == 1 {
            let story = UIStoryboard(name: "Login", bundle: nil)
            let card = story.instantiateViewController(withIdentifier: "Authenticate") as! AuthenticateViewController
            card.fromMine = true
            card.state = state
            card.frontImgPath = self.fImgPath
            card.backgroundPath = self.bImgPath
            card.authCompletion = {
                self.fetchState()
            }
            self.navigationController?.pushViewController(card, animated: true)
        } else {
            guard state != 2 else {
                self.showMessage(message: "正在审核中")
                return
            }
            let story = UIStoryboard(name: "Mine", bundle: nil)
            if state == 1 || self.videoPath == nil {
                let video = story.instantiateViewController(withIdentifier: "video") as! VideoViewController
                self.navigationController?.pushViewController(video, animated: true)
            } else {
                let video = story.instantiateViewController(withIdentifier: "videoplay") as! VideoPlayViewController
                video.videoPath = self.videoPath
                video.change = true
                self.navigationController?.pushViewController(video, animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ViewControllerLightGray()
        title = "认证中心"
        fetchState()
    }
    
    func fetchState() {
        showProgressHUD()
        RJNetworking.CJNetworking().fetchAuthInfo { (response) in
            if response.code == .Success {
                if let cardState = response.response?["card"]["state"].intValue {
                    self.stateArr[1] = cardState
                    self.fImgPath = response.response?["card"]["idcardimg"].stringValue
                    self.bImgPath = response.response?["card"]["unidcardimg"].stringValue
                }
                if let cardState = response.response?["video"]["video_state"].intValue {
                    self.videoPath = response.response?["video"]["videopath"].stringValue
                    self.stateArr[0] = cardState
                }
                self.listView.reloadData()
            }
            self.hideProgressHUD()
        }
    }

}
