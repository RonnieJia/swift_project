//
//  AuthenticateViewController.swift
//  SwiftApp
//

import UIKit
import RJNetworking_Swift
import JXPhotoBrowser

class AuthenticateViewController: RJViewController {

    var fromMine = false
    var state: Int = 1
    var frontImgPath: String?
    var backgroundPath: String?
    var authCompletion: (() -> Void)?
    
    @IBOutlet weak var jumpBtn: RJBackgroundButton!
    @IBOutlet weak var img1: UIButton!
    @IBOutlet weak var img2: UIButton!
    @IBOutlet weak var commitBtn: RJAnimationView!
    
    var selectIndex = 1
    
    var cardImg1: UIImage?
    var cardImg2: UIImage?
    
    var imgPath1: String?
    var imgPath2: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ViewControllerLightGray()
        title = "身份认证"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "help001")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(produceAction))
        
        commitBtn.addTarget(target: self, action: #selector(commitImg), for: .touchUpInside)
        jumpBtn.isHidden = self.fromMine
        
        if fromMine && state > 1 {
            self.commitBtn.isHidden = true
            if self.frontImgPath != nil {
                self.img1.kf.setBackgroundImage(with: URL(string: "\(kCJBaseUrl)\(self.frontImgPath!)"), for: .normal, placeholder: UIImage(named: "addcard001"))
            }
            if self.backgroundPath != nil {
                self.img2.kf.setBackgroundImage(with: URL(string: "\(kCJBaseUrl)\(self.backgroundPath!)"), for: .normal, placeholder: UIImage(named: "addcard001"))
            }
        }
    }
    private func showImg() {
        guard let path = self.selectIndex == 1 ? self.frontImgPath : self.backgroundPath else {
            return
        }
        let browser = JXPhotoBrowser()
        browser.numberOfItems = {
            return 1
        }
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            browserCell?.imageView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(path)"), placeholder: UIImage(named: "zhanwei001"))
        }
        let pageIndicator = JXPhotoBrowserNumberPageIndicator(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        browser.pageIndicator = pageIndicator
        browser.view.addSubview(pageIndicator)
        browser.pageIndex = 0
        browser.reloadData()
        browser.show()
    }
    
    @IBAction func chooseImg(_ sender: UIButton) {
        self.selectIndex = sender.tag
        if self.fromMine && self.state > 1 {
            showImg()
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
    @objc func commitImg() {
        guard cardImg1 != nil && cardImg2 != nil else {
            showMessage(message: "请选择身份证件照片")
            return
        }
        self.imgPath1 = nil
        self.imgPath2 = nil
        let group = DispatchGroup()
        let requestQueue = DispatchQueue(label: "request_queue")
        showProgressHUD()
        for i in 0 ..< 2 {
            group.enter()
            RJNetworking.CJNetworking().uploadImage(self.cardImg1!) { (response, success) in
                if success {
                    let code = response?["code"].intValue
                    if code == 200 {
                        let path = response?["result"]["url"].stringValue
                        if i == 0 {
                            self.imgPath1 = path
                        } else {
                            self.imgPath2 = path
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
            self.authInfo()
        }
        
    }
    
    func authInfo() {
        guard self.imgPath1 != nil && self.imgPath2 != nil else {
            self.hideProgressHUD(message: "图片上传失败，请稍后重试~")
            return
        }
        RJNetworking.CJNetworking().authInfo(self.imgPath1!, unidCard: self.imgPath2!) { (response) in
            if response.code == .Success {
                if self.fromMine {
                    if self.authCompletion != nil {
                        self.authCompletion!()
                    }
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let story = UIStoryboard(name: "Login", bundle: nil)
                    let join = story.instantiateViewController(withIdentifier: "join")
                    self.navigationController?.pushViewController(join, animated: true)
                    
                }
                self.hideProgressHUD()
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    @objc func produceAction() {
        let alert = UIAlertController(title: nil, message: "网络交友存在多方面的风险，初见致力于打造一个真实安全的交友环境。手持证件照可以最大程度的防止冒充他人的行为。为了您与他人的权益，我们对用户实行严格的身份认证。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func jumpAction(_ sender: RJBackgroundButton) {
        sender.touched = false
    }
}


extension AuthenticateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePicker(_ take: Bool) {
        if !self.isAvailableMedia(take) {
            showAlert(title: "请在设置中打开访问\(take ? "相机" : "相册")权限", message: nil)
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = take ? .camera : .photoLibrary
//        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: picker.sourceType)!
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if self.selectIndex == 1 {
                self.cardImg1 = img
                self.img1.setBackgroundImage(img, for: .normal)
            } else {
                self.cardImg2 = img
                self.img2.setBackgroundImage(img, for: .normal)
            }
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
