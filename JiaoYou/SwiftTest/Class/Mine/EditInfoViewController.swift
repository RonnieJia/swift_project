//
//  EditInfoViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/20.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift

class EditInfoViewController: RJViewController {

    @IBOutlet weak var editTableView: UITableView!
    @IBOutlet weak var editBtn: RJAnimationView!
    
    var image: UIImage?
    
    private var cityId: Int?
    
    let titlesArr = ["用户昵称", "出生日期", "身高", "性别", "所在地区", "星座", "职业", "自我介绍"]
    var infoArr = ["请输入昵称", "请选择", "请选择", "请选择", "请选择", "星座", "请输入", "展示最优的自己"]
    
    private var infoContentArr: [Bool] = [false, false, false, false, false, false, false, false, false] {
       didSet {
           self.editTableView.reloadData()
       }
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editTableView.backgroundColor = .white
        editTableView.tableFooterView = UIView()
        view.backgroundColor = .white
        title = "个人编辑页"
        let user = CurrentUser.sharedInstance
        infoArr = [user.nickname ?? "", user.birthday ?? "", "\(user.height)", "\(user.userSex == .boy ? "男" : "女")", user.address ?? "", user.constellation ?? "", user.occupation ?? "", user.self_info ?? ""]
        avatarImgView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(user.avatarUrl!)"), placeholder: UIImage(named: "defaultUserIcon"))
        editBtn.addTarget(target: self, action: #selector(editInfo), for: .touchUpInside)
        editBtn.backgroundColor = UIColor.red
        _createHeaderView()
    }
    
    @objc private func editInfo() {
        if self.image != nil {
            showProgressHUD()
            RJNetworking.CJNetworking().uploadImage(self.image!) { (response, success) in
                if success {
                    let code = response?["code"].intValue
                    if code == 200 {
                        let path = response?["result"]["url"].stringValue
                        self.commitInfo(path!)
                    } else {
                        let msg = response?["msg"].stringValue
                        self.hideProgressHUD(message: msg)
                    }
                } else {
                    self.hideProgressHUD(message: "图片上传失败，请稍后重试~")
                }
            }
        } else {
            var hadChange = false
            for change in infoContentArr {
                if change {
                    hadChange = true
                    break
                }
            }
            if hadChange {// 如果有修改内容
                showProgressHUD()
                commitInfo(nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func commitInfo(_ path: String?) {
        let height = fetchChangeValue(2)
        RJNetworking.CJNetworking().editInfo(path, nick: fetchChangeValue(0), birthday: fetchChangeValue(1), height: height != nil ? Int((height! as NSString).intValue) : nil, sex: nil, city: self.cityId != nil ? "\(self.cityId!)" : nil, intro: fetchChangeValue(7), occupation: fetchChangeValue(6)) { (response) in
            if response.code == .Success {
                if self.cityId != nil && self.cityId ?? 0 > 0 {
                    CurrentUser.sharedInstance.city_id = self.cityId!
                    UserDefaults.standard.set(CurrentUser.sharedInstance.city_id, forKey: "city_id")
                    UserDefaults.standard.synchronize()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changecity"), object: nil)
                }
                let deadline = DispatchTime.now() + 0.8
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            self.hideProgressHUD(message: response.message)
            
        }
    }
    
    
    private func _createHeaderView() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 150))
        header.addSubview(self.avatarImgView)
        avatarImgView.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(0)
            make?.top.mas_equalTo()(20)
            make?.size.mas_equalTo()(CGSize(width: 76, height: 76))
        }
        let label = RJLabel(font: UIFont.systemFont(ofSize: 12), textColor: .lightGray, textAlignment: .center, text: "用户头像")
        header.addSubview(label)
        label.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(0)
            make?.top.equalTo()(avatarImgView.mas_bottom)?.offset()(10)
        }
        editTableView.tableHeaderView = header
    }
    
    
    private func fetchUserInfo(_ msg: String?) {
        RJNetworking.CJNetworking().userInfo { (response) in
            if response.code == .Success{
                CurrentUser.sharedInstance.userInfo(response.response?["info"])
            }
            let deadline = DispatchTime.now() + 0.8
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.navigationController?.popViewController(animated: true)
            }
            self.hideProgressHUD(message: msg)
        }
        
    }
    
    private func fetchChangeValue(_ index: Int) -> String? {
        if index < infoContentArr.count && infoContentArr[index] {
            return infoArr[index]
        }
        return nil
    }
    
    private lazy var dateInputView: InfoEditInputView = {
        let date = InfoEditInputView(.date)
        date.editChoose = { [unowned self] (str: String) in
            self.infoArr[1] = str
            self.infoContentArr[1] = true
        }
        return date
    }()
    
    lazy var avatarImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.cornerRadius = 38
        imgView.image = UIImage(named: "defaultUserIcon")
        imgView.contentMode = .scaleToFill
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseAvatarImage)))
        return imgView
    }()
    
    private lazy var heightInputView: InfoEditInputView = {
        let height = InfoEditInputView(.height)
        height.editChoose = { [unowned self] (str: String) in
            self.infoArr[2] = str
            self.infoContentArr[2] = true
        }
        return height
    }()
    
    private lazy var addressInputView: InfoEditInputView = {
        let address = InfoEditInputView(.address)
        address.addressChoose = { [unowned self] (str: String, cid: Int) in
            self.cityId = cid
            self.infoArr[4] = str
            self.infoContentArr[4] = true
        }
        return address
    }()
}

extension EditInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let storyboaed = UIStoryboard(name: "Mine", bundle: nil)
            let nick = storyboaed.instantiateViewController(withIdentifier: "editnick") as! EditNickViewController
            let str = infoArr[indexPath.row]
            if !str.isEmpty && str != "请输入昵称" {
                nick.nick = str
            }
            nick.editNickCompltion = { [unowned self] (nickName) in
                self.infoArr[0] = nickName
                self.infoContentArr[0] = true
            }
            navigationController?.pushViewController(nick, animated: true)
        case 1:
            self.dateInputView.show()
        case 2:
            self.heightInputView.show()
        case 3:
            showMessage(message: "性别不允许修改")
        case 4:
            self.addressInputView.show()
        case 5:
            showMessage(message: "星座根据出生日期自动修改")
        case 6:
            let storyboaed = UIStoryboard(name: "Mine", bundle: nil)
            let nick = storyboaed.instantiateViewController(withIdentifier: "editnick") as! EditNickViewController
            nick.zhiye = true
            let str = infoArr[indexPath.row]
            if !str.isEmpty && str != "请输入" {
                nick.nick = str
            }
            nick.editNickCompltion = { [unowned self] (nickName) in
                self.infoArr[6] = nickName
                self.infoContentArr[6] = true
            }
            navigationController?.pushViewController(nick, animated: true)
        default:
            let storyboaed = UIStoryboard(name: "Mine", bundle: nil)
            let intro = storyboaed.instantiateViewController(withIdentifier: "suggest") as! SuggestViewController
            let str = infoArr[indexPath.row]
            if !str.isEmpty && str != "展示最优的自己" {
                intro.showText = str
            }
            intro.userInfo = true
            intro.editUserInfo = { [unowned self] (info) in
                self.infoArr[7] = info
                self.infoContentArr[7] = true
            }
            navigationController?.pushViewController(intro, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titlesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editinfocell", for: indexPath)
        if let titleL = cell.contentView.viewWithTag(100) as? UILabel {
            titleL.text = titlesArr[indexPath.row]
        }
        if let titleL2 = cell.contentView.viewWithTag(101) as? UILabel {
            titleL2.text = infoArr[indexPath.row]
        }
        
        return cell
    }
}


extension EditInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc private func chooseAvatarImage() {
        let chooseImg = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        chooseImg.addAction(UIAlertAction(title: "拍照", style: .default, handler: { (action) in
            self.showImagePicker(true)
        }))
        chooseImg.addAction(UIAlertAction(title: "从相册选择", style: .default, handler: { (action) in
            self.showImagePicker(false)
        }))
        chooseImg.addAction(UIAlertAction(title: "拍照", style: .cancel, handler: nil))
        self.present(chooseImg, animated: true, completion: nil)
    }
    
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
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.image = img
            self.editTableView.reloadData()
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

