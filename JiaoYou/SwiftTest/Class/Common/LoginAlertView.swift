//
//  LoginAlertView.swift
//  SwiftApp
//
//  Created by 辉贾 on 2020/5/7.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class LoginAlertView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupViews()
    }
    
    private var payBlock: ((_ type: Int) -> Void)?
    
    var tableView: UITableView = UITableView(frame: CGRect(x: autoSize(60), y: 0, width: kScreenWidth - autoSize(120), height: 180))
    
    func _setupViews() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        
        self.addSubview(tableView)
        tableView.centerY(kScreenHeight / 2)
        tableView.clipsToBounds = true
        tableView.cornerRadius = 16
        tableView.rowHeight = 40
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 60))
        tableView.tableHeaderView = header
        let line = UIView(frame: CGRect(x: 0, y: 59, width: header.width, height: 0.6))
        line.backgroundColor = UIColor.lightGray
        header.addSubview(line)
        let headLabel = RJLabel(frame: CGRect(x: 0, y: 10, width: header.width, height: 40), font: UIFont.systemFont(ofSize: 14), textColor: UIColor.darkGray, textAlignment: .center, text: "请登录或注册您的账号")
        header.addSubview(headLabel)
        header.addGestureRecognizer(UITapGestureRecognizer())
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideSelf))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    @objc func actionClick() {
        self.hideSelf()
        if self.payBlock != nil {
            
        }
    }
    
    static func show(_ vipBlock: @escaping (_ type: Int) -> Void) {
        let vipView = LoginAlertView(frame: UIScreen.main.bounds)
        vipView.payBlock = vipBlock
        UIApplication.shared.keyWindow?.addSubview(vipView)
    }
    
    @objc func hideSelf() {
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension LoginAlertView: UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        let label = RJLabel(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 40), font: UIFont.boldSystemFont(ofSize: 16), textColor: UIColor.systemBlue, textAlignment: .center, text: indexPath.row == 0 ? "登录" : (indexPath.row == 1 ? "注册" : "再逛逛"))
        cell.contentView.addSubview(label)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.hideSelf()
        if self.payBlock != nil {
            self.payBlock!(indexPath.row)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isKind(of: LoginAlertView.self) ?? true {
            return true
        }
        return false
    }
}


