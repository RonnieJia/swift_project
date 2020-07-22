//
//  VideoPlayViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/5/8.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import AVKit
import RJNetworking_Swift
import JMessage

class VideoPlayViewController: RJViewController {

    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var videoPlayView: UIView!
    @IBOutlet weak var commitBtn: UIButton!
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    var fitst: Bool = true
    
    var followBlock: ((_ follow: Int) -> Void)?
    var videoPath: String?
    var local: Bool = false
    var change: Bool = false
    var chat: Bool = false
    var user: HomeModel?
    
    var playItem: AVPlayerItem?
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    func playVideo() {
        if self.player != nil {
            self.player = nil
        }
        if self.playerLayer != nil {
            self.playerLayer?.removeFromSuperlayer()
            self.playerLayer = nil
        }
        if self.playItem != nil {
            self.playItem = nil
        }
        if self.local {
            self.playItem = AVPlayerItem(url: URL(fileURLWithPath: self.videoPath!))
        } else {
            self.playItem = AVPlayerItem(url: URL(string: "\(kCJBaseUrl)\(self.videoPath!)")!)
        }
        player = AVPlayer(playerItem: self.playItem!)
        playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer?.frame = self.videoPlayView.bounds
        self.videoPlayView.layer.insertSublayer(self.playerLayer!, at: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "视频认证"
        if self.change {
            self.commitBtn.setTitle("更改", for: .normal)
        } else if self.chat {
            chatBtn.isHidden = false
            followBtn.isHidden = false
            commitBtn.isHidden = true
            warnLabel.isHidden = true
            title = "认证的视频"
            followBtn.isSelected = self.user?.follow == 1
            
            chatBtn.layer.shadowColor = UIColor.black.cgColor;
            chatBtn.layer.shadowOffset = CGSize(width: 0, height: 5)
            chatBtn.layer.shadowRadius = 5;
            chatBtn.layer.shadowOpacity = 0.5;
            
            followBtn.layer.shadowColor = UIColor.black.cgColor;
            followBtn.layer.shadowOffset = CGSize(width: 0, height: 5)
            followBtn.layer.shadowRadius = 5;
            followBtn.layer.shadowOpacity = 0.5;
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoPlayComplete), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        playVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func videoPlayComplete() {
        DispatchQueue.main.async {
            self.playBtn.isHidden = false
        }
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        if fitst {
            self.player?.volume = 0
            self.player?.play()
        } else {
            playVideo()
            self.player?.volume = 0
            self.player?.play()
        }
        fitst = false
        sender.isHidden = true
    }
    
    @IBAction func commitAction(_ sender: UIButton) {
        if self.change {
            let story = UIStoryboard(name: "Mine", bundle: nil)
            let record = story.instantiateViewController(withIdentifier: "video")
            self.navigationController?.pushViewController(record, animated: true)
            return
        }
        
        showProgressHUD()
        RJNetworking.sharedInstance.uploadVideo(self.videoPath!) { (response, success) in
            if success {
                if let str = response?["result"]["url"].stringValue {
                    self.videoAuth(str)
                } else {
                    self.hideProgressHUD(message: "上传失败，稍后再试")
                }
            } else {
                self.hideProgressHUD(message: "上传失败，稍后再试")
            }
        }
    }
    
    @IBAction func followAction(_ sender: UIButton) {
        if CurrentUser.isVisitor() {
            self.showLoginAlert()
            return
        }
        guard let uid = user?.user_id else {
            return
        }

        if uid == CurrentUser.sharedInstance.userId {
            showMessage(message: "不能关注自己~")
            return
        }
        showProgressHUD()
        RJNetworking.CJNetworking().followUser(uid) { (response) in
            if response.code == .Success {
                if let cancel = response.message?.contains("取关"), cancel {
                    self.user?.follow = 2
                } else {
                    self.user?.follow = 1
                }
                self.followBtn.isSelected = self.user?.follow == 1
                if self.followBlock != nil {
                    self.followBlock!(self.user?.follow ?? 2)
                }
            }
            self.hideProgressHUD(message: response.message)
            
        }
    }
    @IBAction func chatAction(_ sender: UIButton) {
        if CurrentUser.isVisitor() {
            self.showLoginAlert()
            return
        }
        JMSGConversation.createSingleConversation(withUsername: self.user!.jmuserName) { (result, error) in
            if let conversion = result as? JMSGConversation {
                let chatVC = ChatViewController(conversation: conversion)
                self.navigationController?.pushViewController(chatVC, animated: true)
            } else {
                self.showMessage(message: "发生错误，稍后再试")
            }
        }
    }
    func videoAuth(_ path: String) {
        RJNetworking.CJNetworking().authVideo(path) { (response) in
            if response.code == .Success {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            self.hideProgressHUD(message: response.message)
        }
    }
    
    deinit {
        self.player?.pause()
        self.player = nil
        self.playerLayer = nil
        self.playItem = nil
        if self.local {
            try? FileManager.default.removeItem(atPath: self.videoPath!)
        }
    }
}
