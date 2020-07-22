//
//  PrefectInfoViewController.swift
//  SwiftApp
import RJUtils_Swift
import UIKit
import RJNetworking_Swift

class PrefectInfoViewController: RJViewController, UITableViewDelegate, UITableViewDataSource {

    var image: UIImage?
    var cityId: Int = -1
    let titlesArr = ["用户昵称", "出生日期", "身高", "性别", "所在地区", "职业",  "自我介绍"]
    var infoArr = ["请输入昵称", "请选择", "请选择", "请选择", "请选择", "请输入", "展示最优的自己"]
    var infoContentArr = ["", "", "", "", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = RJViewColor.grayBackground.viewColor()
        title = "完善资料"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.rowHeight = 40
        tableView.tableFooterView = UIView()
        view.addSubview(self.tableView)
        tableView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets.zero)
        }
        
        let barItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(compleAction))
        navigationItem.rightBarButtonItem = barItem
        /*
        let compleBtn = RJAnimationView()
        compleBtn.title = "完成"
        compleBtn.setupBtn()
        compleBtn.frame = CGRect(x: 30, y: (kScreenHeight - kNavigatioBarHeight - 280.0 - 46) / 2.0 + 280, width: kScreenWidth-60, height: 46)
        compleBtn.cornerRadius = 23
        view.addSubview(compleBtn)
        compleBtn.addTarget(target: self, action: #selector(compleAction), for: .touchUpInside)
        */
        _createHeaderView()
    }
    
    private func _createHeaderView() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 150))
        header.addSubview(self.avatarImgView)
        avatarImgView.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(0)
            make?.top.mas_equalTo()(20)
            make?.size.mas_equalTo()(CGSize(width: 76, height: 76))
        }
        let label = RJLabel(font: UIFont.systemFont(ofSize: 12), textColor: .lightGray, textAlignment: .center, text: "请上传用户头像")
        header.addSubview(label)
        label.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(0)
            make?.top.equalTo()(avatarImgView.mas_bottom)?.offset()(10)
        }
        tableView.tableHeaderView = header
    }
    
    @objc private func compleAction() {
        guard self.image != nil else {
            showMessage(message: "请选择头像")
            return
        }
        guard !infoContentArr[0].isEmpty else {
            showMessage(message: "请输入昵称")
            return
        }
        guard !infoContentArr[1].isEmpty else {
            showMessage(message: "请选择出生日期")
            return
        }
        guard !infoContentArr[2].isEmpty else {
            showMessage(message: "请选择身高")
            return
        }
        guard !infoContentArr[3].isEmpty else {
            showMessage(message: "请选择性别")
            return
        }
        guard !infoContentArr[4].isEmpty else {
            showMessage(message: "请选择所在地")
            return
        }
        guard !infoContentArr[5].isEmpty else {
            showMessage(message: "请输入职业")
            return
        }
        guard !infoContentArr[6].isEmpty else {
            showMessage(message: "请输入自我介绍")
            return
        }
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
    }
    
    private func commitInfo(_ path: String) {
        RJNetworking.CJNetworking().improveData(path, nick: infoContentArr[0], birthday: infoContentArr[1], height: Int((infoContentArr[2] as NSString).intValue), sex: (infoContentArr[3] == "男" ? 1 : 2), city: "\(self.cityId)", intro: infoContentArr[6], occupation: infoContentArr[5]) { (response) in
            if response.code == .Success {
                self.hideProgressHUD()
                CurrentUser.sharedInstance.city_id = self.cityId
                let story = UIStoryboard(name: "Login", bundle: nil)
                let auth = story.instantiateViewController(withIdentifier: "join")
                self.navigationController?.pushViewController(auth, animated: true)
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    @objc private func chooseAvatarImage() {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titlesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = PrefectTableViewCell.cell(with: tableView) as PrefectTableViewCell
        cell.titleL?.text = titlesArr[indexPath.row]
        var info = infoContentArr[indexPath.row]
        if info.isEmpty {
            cell.infoL?.setTitleColor(UIColor.lightGray, for: .normal)
            info = infoArr[indexPath.row]
        } else {
            cell.infoL?.setTitleColor(UIColor.black, for: .normal)
        }
        cell.infoL?.setTitle(info, for: .normal)
        cell.index = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            let storyboaed = UIStoryboard(name: "Mine", bundle: nil)
            let nick = storyboaed.instantiateViewController(withIdentifier: "editnick") as! EditNickViewController
            nick.editNickCompltion = { [unowned self] (nickName) in
                self.infoContentArr[0] = nickName
                self.tableView.reloadData()
            }
            navigationController?.pushViewController(nick, animated: true)
        } else if (indexPath.row == 1) {
            self.dateInputView.show()
        } else if (indexPath.row == 2) {
            self.heightInputView.show()
        } else if (indexPath.row == 3) {
            self.showMessage(message: "性别选定后不可更改")
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "男", style: .default, handler: { (action) in
                self.infoContentArr[3] = "男"
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "女", style: .default, handler: { (action) in
                self.infoContentArr[3] = "女"
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if (indexPath.row == 4) {
            self.addressInputView.show()
        } else if (indexPath.row == 5) {
            let storyboaed = UIStoryboard(name: "Mine", bundle: nil)
            let nick = storyboaed.instantiateViewController(withIdentifier: "editnick") as! EditNickViewController
            nick.zhiye = true
            nick.editNickCompltion = { [unowned self] (nickName) in
                self.infoContentArr[5] = nickName
                self.tableView.reloadData()
            }
            navigationController?.pushViewController(nick, animated: true)
        } else {
            let story = UIStoryboard(name: "Mine", bundle: nil)
            let info = story.instantiateViewController(withIdentifier: "suggest") as! SuggestViewController
            info.userInfo = true
            info.editUserInfo = { [unowned self] (infoStr) in
                self.infoContentArr[indexPath.row] = infoStr
                self.tableView.reloadData()
            }
            navigationController?.pushViewController(info, animated: true)
        }
    }
    
    lazy var avatarImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.cornerRadius = 38
        imgView.image = UIImage(named: "defaultUserIcon")
        imgView.contentMode = .scaleToFill
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseAvatarImage)))
        return imgView
    }()

    lazy var dateInputView: InfoEditInputView = {
        let date = InfoEditInputView(.date)
        date.editChoose = { [unowned self] (str: String) in
            self.infoContentArr[1] = str
            self.tableView.reloadData()
        }
        return date
    }()
    
    lazy var heightInputView: InfoEditInputView = {
        let height = InfoEditInputView(.height)
        height.editChoose = { [unowned self] (str: String) in
            self.infoContentArr[2] = str
            self.tableView.reloadData()
        }
        return height
    }()
    
    lazy var addressInputView: InfoEditInputView = {
        let address = InfoEditInputView(.address)
        address.addressChoose = { [unowned self] (str: String, cid: Int) in
            self.cityId = cid
            self.infoContentArr[4] = str
            self.tableView.reloadData()
        }
        return address
    }()
}

extension PrefectInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            self.avatarImgView.image = img
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

