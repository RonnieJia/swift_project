//
//  ReportViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/14.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift

class ReportViewController: RJViewController {

    let cellIdetifier = "reportCell"
    
    var uid: Int?
    
    var selectedIndex = -1
    
    var image: UIImage?
    
    var imgBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "举报"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .done, target: self, action: #selector(commitAction))
        
        view.addSubview(self.tableView)
        tableView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets.zero)
        }
        tableView.rowHeight = 40
        tableView.register(ReportTableViewCell.self, forCellReuseIdentifier: cellIdetifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 46))
        tableView.tableHeaderView = header
        let hWView = UIView(frame: CGRect(x: 0, y: 10, width: kScreenWidth, height: 35))
        hWView.backgroundColor = .white
        header.addSubview(hWView)
        hWView.addSubview(RJLabel(frame: CGRect(x: 17, y: 5, width: kScreenWidth - 33, height: 25), text: "举报理由"))
        
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 200))
        tableView.tableFooterView = footer
        let whiteView = UIView(frame: CGRect(x: 0, y: 25, width: kScreenWidth, height: 160))
        whiteView.backgroundColor = .white
        footer.addSubview(whiteView)
        whiteView.addSubview(RJLabel(frame: CGRect(x: 17, y: 5, width: kScreenWidth - 33, height: 24), text: "举报证据"))
        imgBtn = RJImageButton(frame: CGRect(x: 15, y: 35, width: 108, height: 108), backgroundImage: UIImage(named: "addimg001"))
        whiteView.addSubview(imgBtn!)
        imgBtn?.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        
        
    }
    
    @objc func commitAction() {
        guard self.selectedIndex >= 0 else {
            showMessage(message: "请选择举报该用户的理由")
            return
        }
        let alert = UIAlertController(title: "确定举报该用户？", message: nil, preferredStyle: .alert)
        let lhAction = UIAlertAction.init(title: "举报", style: .default, handler: { [weak self] (action) in
            self?.showProgressHUD()
            if self?.image != nil {
                self?.uploadImage()
            } else {
                self?.commitReportInfo(nil)
            }
        })
        lhAction.setValue(UIColor.red, forKey: "_titleTextColor")
        alert.addAction(lhAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func uploadImage() {
        RJNetworking.CJNetworking().uploadImage(self.image!) { (response, success) in
            if success {
                let code = response?["code"].intValue
                if code == 200 {
                    let path = response?["result"]["url"].stringValue
                    self.commitReportInfo(path)
                } else {
                    let msg = response?["msg"].stringValue
                    self.hideProgressHUD(message: msg)
                }
            } else {
                self.hideProgressHUD(message: "图片上传失败，请稍后重试~")
            }
        }
    }
    
    func commitReportInfo(_ path: String?) {
        RJNetworking.CJNetworking().report(with: uid!, reason: dataArr[self.selectedIndex], pic: path) { (response) in
            if response.code == .Success {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
                    self.navigationController?.popViewController(animated: true)
                }
                self.hideProgressHUD(message: "举报成功")
            } else {
            self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    var dataArr = ["色情骚扰", "暴力", "广告", "欺诈", "头像不雅", "昵称不雅", "其他"]
}

extension ReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdetifier, for: indexPath) as! ReportTableViewCell
        if indexPath.row % 2 == 0 {
            cell.containerView?.backgroundColor = .white
        } else {
            cell.containerView?.backgroundColor = RGBAColor(238, 238, 238, 1)
        }
        cell.titleLabel?.text = dataArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
    }
    
}

extension ReportViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func takePhoto() {
        let chooseImg = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        chooseImg.addAction(UIAlertAction(title: "拍照", style: .default, handler: { (action) in
            self.showImagePicker(true)
        }))
        chooseImg.addAction(UIAlertAction(title: "从相册选择", style: .default, handler: { (action) in
            self.showImagePicker(false)
        }))
        chooseImg.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(chooseImg, animated: true, completion: nil)
    }
    
    private func showImagePicker(_ take: Bool) {
        if !self.isAvailableMedia(take) {
            showAlert(title: "请在设置中打开访问\(take ? "相机" : "相册")权限", message: nil)
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = take ? .camera : .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: picker.sourceType)!
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = img
            imgBtn?.setBackgroundImage(img, for: .normal)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // 退出图片选择控制器
        picker.dismiss(animated: true, completion: nil)
    }
    
    func isAvailableMedia(_ take: Bool) -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(take ? .camera : .photoLibrary)
    }
}
