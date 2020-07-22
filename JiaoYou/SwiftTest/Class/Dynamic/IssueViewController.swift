//
//  IssueViewController.swift
//  SwiftApp
//

import UIKit
import RJNetworking_Swift

class IssueViewController: RJViewController {

    var imageArr: [UIImage] = []
    var imagePathArr: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "上传动态"
        view.backgroundColor = ViewControllerLightGray()
        
        let issueView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 200))
        issueView.backgroundColor = .white
        view.addSubview(issueView)
        
        let label = RJLabel(frame: CGRect(x: 18, y: 20, width: 200, height: 16), text: "图片动态")
        issueView.addSubview(label)
        
        let wid = (kScreenWidth - 50) / 3.0
        let hei = wid * 88 / 101
        for i in 0 ..< 3 {
            let item = RJImageButton(frame: CGRect(x: 15 + (wid + 10) * CGFloat(i), y: label.bottom + 8, width: wid, height: hei), backgroundImage: UIImage(named: "add002"))
            item.isHidden = i > 0
            item.tag = 100 + i
            issueView.addSubview(item)
            item.addTarget(self, action: #selector(addImage(_:)), for: .touchUpInside)
            item.cornerRadius = 4
            item.clipsToBounds = true
            
            let closeBtn = RJImageButton(frame: CGRect(x: wid - 30, y: 4, width: 26, height: 26), backgroundImage: UIImage(named: "close001"))
            item.addSubview(closeBtn)
            closeBtn.tag = 200 + i
            closeBtn.isHidden = true
            closeBtn.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        }
        
        let compleBtn = RJAnimationView()
        compleBtn.title = "提交"
        compleBtn.setupBtn()
        compleBtn.frame = CGRect(x: 30, y: (kScreenHeight - kNavigatioBarHeight - 280.0 - 46) / 2.0 + 280, width: kScreenWidth-60, height: 46)
        compleBtn.cornerRadius = 23
        view.addSubview(compleBtn)
        compleBtn.addTarget(target: self, action: #selector(compleAction), for: .touchUpInside)
    }
    
    @objc func addImage(_ sender: UIButton) {
        if sender.tag - 100 < imageArr.count {
            return
        }
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
    
    @objc func deleteImage(_ sender: UIButton) {
        if sender.tag - 200 >= imageArr.count {
            return
        }
        imageArr.remove(at: sender.tag - 200)
        self.display()
    }
    
    func display() {
        for i in 0 ..< 3 {
            let btn = view.viewWithTag(100 + i) as! UIButton
            let closeBtn = btn.viewWithTag(200 + i) as! UIButton
            btn.isHidden = i > imageArr.count
            if i < imageArr.count {
                closeBtn.isHidden = false
                btn.setBackgroundImage(imageArr[i], for: .normal)
            } else {
                closeBtn.isHidden = true
                btn.setBackgroundImage(UIImage(named: "add002"), for: .normal)
                
            }
        }
    }
    
    @objc func compleAction() {
        if imageArr.count > 0 {
            imagePathArr.removeAll()
            showProgressHUD()
            let group = DispatchGroup()
            let requestQueue = DispatchQueue(label: "request_queue")
            showProgressHUD()
            for img in imageArr {
                group.enter()
                RJNetworking.CJNetworking().uploadImage(img) { (response, success) in
                    if success {
                        let code = response?["code"].intValue
                        if code == 200 {
                            if let path = response?["result"]["url"].stringValue {
                                self.imagePathArr.append(path)
                            }
                        } else {
                            let msg = response?["msg"].stringValue
                            self.hideProgressHUD(message: msg)
                        }
                    } else {
                        self.hideProgressHUD(message: "图片上传失败，请稍后重试~")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: requestQueue) {
                self.commitInfo()
            }
        } else {
            self.showMessage(message: "请添加图片")
        }
    }
    
    func commitInfo() {
        if imagePathArr.count == imageArr.count {
            RJNetworking.CJNetworking().addShow(imagePathArr.joined(separator: ",")) { (response) in
                if response.code == .Success {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                self.hideProgressHUD(message: response.message)
            }
            
        }
    }
}

extension IssueViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePicker(_ take: Bool) {
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
            self.imageArr.append(img)
            self.display()
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

