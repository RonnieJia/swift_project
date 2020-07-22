//
//  SettingViewController.swift
//  SwiftApp

import UIKit
import JMessage

class SettingViewController: RJViewController {
    
    @IBOutlet weak var logout: RJAnimationView!
    
    @IBOutlet weak var setTableView: UITableView!
    
    var dataArr = ["清除缓存", "黑名单", "意见反馈", "关于平台"]//"帮助与引导",
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设置"
        view.backgroundColor = ViewControllerLightGray()
        logout?.addTarget(target: self, action: #selector(logoutClick), for: .touchUpInside)
    }
    
    @objc func logoutClick() {
        let sheet = UIAlertController(title: nil, message: "确认退出", preferredStyle: .actionSheet)
        let lhAction = UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                UserDefaults.standard.removeObject(forKey: "uid")
                UserDefaults.standard.removeObject(forKey: "city_id")
                UserDefaults.standard.synchronize()
                CurrentUser.sharedInstance.loginJM = false
                JMSGUser.logout { (result, err) in
                    
                }
                MobClick.profileSignOff()
                let story = UIStoryboard(name: "Login", bundle: nil)
                let login = story.instantiateViewController(withIdentifier: "LoginEntance") as! LoginEntanceViewController
                appDelegate.window?.rootViewController = RJNavigationController(rootViewController: login)
                /*
                let storyBoard = UIStoryboard(name: "Login", bundle: nil)
                if #available(iOS 13.0, *) {
                    let loginEntry = storyBoard.instantiateViewController(withIdentifier: "LoginEntry2")
                    appDelegate.window?.rootViewController = RJNavigationController(rootViewController: loginEntry)
                } else {
                    let loginEntry = storyBoard.instantiateViewController(withIdentifier: "LoginEntry")
                    appDelegate.window?.rootViewController = RJNavigationController(rootViewController: loginEntry)
                }
 */
            }
        })
        sheet.addAction(lhAction)
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }

}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let titleL = cell.contentView.viewWithTag(100) as? UILabel {
            titleL.text = dataArr[indexPath.row]
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {// 清除缓存
            removeCache()
        } else {
            let storyboard = UIStoryboard(name: "Mine", bundle: nil)
            if indexPath.row == 100 {// 帮助引导
                let help = storyboard.instantiateViewController(withIdentifier: "help")
                self.navigationController?.pushViewController(help, animated: true)
            } else if (indexPath.row == 1) {
                let blacklist = storyboard.instantiateViewController(withIdentifier: "blacklist")
                self.navigationController?.pushViewController(blacklist, animated: true)
            } else if (indexPath.row == 2) {
                let suggest = storyboard.instantiateViewController(withIdentifier: "suggest")
                self.navigationController?.pushViewController(suggest, animated: true)
            } else if indexPath.row == 3 {
                let help = storyboard.instantiateViewController(withIdentifier: "help") as! HelpGuideViewController
                help.type = 4
                self.navigationController?.pushViewController(help, animated: true)
            }
        }
    }
    
    func removeCache() {
        showProgressHUD()
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: cachePath) else {
            return
        }
        if let paths = fileManager.subpaths(atPath: cachePath) {
            for fileName in paths {
//                if fileName.contains("Preferences") { continue }
                let filePath = cachePath.appending("/\(fileName)")
                if fileManager.fileExists(atPath: filePath) {
                    do {
                        try fileManager.removeItem(atPath: filePath)
                    } catch  {
                        
                    }
                }
            }
        }
        let deadline = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.hideProgressHUD(message: "清除成功")
        }
    }
    
    func cacheSize() -> CGFloat {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: cachePath) else {
            return 0
        }
        var totalSize: CGFloat = 0
        if let paths = fileManager.subpaths(atPath: cachePath) {
            for fileName in paths {
//                if fileName.contains("Preferences") { continue }
                let subSize = fileSize(at: cachePath.appending("/\(fileName)"))
                totalSize += subSize
            }
        }
        return totalSize / 1024 / 1024
    }
    
    func fileSize(at path: String) -> CGFloat {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                let obj = try fileManager.attributesOfItem(atPath: path)
                return obj[FileAttributeKey.size] as! CGFloat
            } catch {
                fatalError("error")
            }
        }
        return 0
    }
    
}
