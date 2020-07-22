        //
//  RJChuJianNetworking.swift
//  SwiftApp
//
//  Created by jia on 2020/4/22.
//  Copyright © 2020 RJ. All rights reserved.
//

import RJNetworking_Swift
import Alamofire
import SwiftyJSON

/// https://www.showdoc.cc/chujian?page_id=4302708675905345
/// tongyi100




extension RJNetworking {
    static func CJNetworking() -> RJNetworking {
        let net = RJNetworking.sharedInstance
        net.kBaseUrl = "\(kCJBaseUrl)api/"
        net.responseKey = "result"
        return net
    }
    
    ///  注册
    /// - Parameter phone: 手机号
    /// - Parameter pwd: 密码
    /// - Parameter code: 验证码
    func regis(_ phone: String, pwd: String, code: String, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["phone": phone, "pwd": pwd, "code": code, "type": 1] as [String : Any]
        self.POSTRequest(with: "index/user_reg", paramters: paramters, completion: completion)
    }
    
    /// 获取验证码
    /// - Parameters:
    ///   - phone: 手机号
    ///   - type: 1- 2-
    func fetchCode(_ phone: String, type: Int? = 1, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["phone": phone, "type": type!] as [String : Any]
        self.POSTRequest(with: "index/send_code", paramters: paramters, completion: completion)
    }
    
    /// 完善信息
    /// - Parameter avator: 头像
    /// - Parameter nick: 昵称
    /// - Parameter birthday: 生日
    /// - Parameter height: 身高
    /// - Parameter sex: 性别 1-男 2-女
    /// - Parameter city: 城市id
    /// - Parameter intro: 简介
    func improveData(_ avator: String, nick: String, birthday: String, height: Int, sex: Int = 2, city: String, intro: String, occupation:String, completion: @escaping (_ response: RJResponse) -> Void) {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy-MM-dd"
        let date = dateformat.date(from: birthday)
        let time = date?.timeIntervalSince1970 ?? 0
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "avatarUrl": avator, "nickname": nick, "birthday": time, "height": height, "sex": sex, "city_id": city, "self_info": intro, "occupation": occupation] as [String : Any]
        self.POSTRequest(with: "index/perfect_info", paramters: paramters, completion: completion)
    }
    
    /// 修改信息
    /// - Parameter avator: 头像
    /// - Parameter nick: 昵称
    /// - Parameter birthday: 生日
    /// - Parameter height: 身高
    /// - Parameter sex: 性别 1-男 2-女
    /// - Parameter city: 城市id
    /// - Parameter intro: 简介
    func editInfo(_ avator: String? = nil, nick: String? = nil, birthday: String? = nil, height: Int? = nil, sex: Int? = nil, city: String? = nil, intro: String? = nil, occupation: String? = nil, completion: @escaping (_ response: RJResponse) -> Void) {
        var paramters: [String: Any] = [:]
        paramters["uid"] = CurrentUser.sharedInstance.userId
        if birthday != nil && !birthday!.isEmpty {
            let dateformat = DateFormatter()
            dateformat.dateFormat = "yyyy-MM-dd"
            let date = dateformat.date(from: birthday!)
            let time = date?.timeIntervalSince1970 ?? 0
            paramters["birthday"] = time
        }
        if avator != nil && !avator!.isEmpty {
            paramters["avatarUrl"] = avator!
        }
        if nick != nil && !nick!.isEmpty {
            paramters["nickname"] = nick!
        }
        if height != nil && height! > 0 {
            paramters["height"] = height!
        }
        if sex != nil {
            paramters["sex"] = sex!
        }
        if city != nil && !city!.isEmpty {
            paramters["city_id"] = city!
        }
        if intro != nil && !intro!.isEmpty {
            paramters["self_info"] = intro!
        }
        if occupation != nil && !occupation!.isEmpty {
            paramters["occupation"] = occupation!
        }
        self.POSTRequest(with: "index/edit_info", paramters: paramters, completion: completion)
    }
    
    
    /// 上传图片
    func uploadVideo(_ video: String, completion: @escaping (_ response: JSON?, _ success: Bool) -> Void) {
        if let videoData = try? Data(contentsOf: URL(fileURLWithPath: video)) {
            let URL = try! URLRequest(url: "\(kCJBaseUrl)api/index/upload", method: .post, headers: nil)
            Alamofire.upload(multipartFormData: { (multipartFormData) in
              multipartFormData.append(videoData, withName: "file", fileName: "video.mp4", mimeType: "video/mp4")
            }, with: URL) { (result) in
              switch result {
              case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                  print("Upload Progress: \(progress.fractionCompleted)")
                })
                upload.responseJSON { response in
                    if response.data != nil {
                        completion(JSON(response.data!), true)
                    } else {
                        completion(nil, false)
                    }
                }
              case .failure(let encodingError):
                    completion(nil, false)
                    print(encodingError)

              }
            }
        } else {
            completion(nil, false)
        }
        
    }
    
    /// 上传图片
    func uploadImage(_ image: UIImage, completion: @escaping (_ response: JSON?, _ success: Bool) -> Void) {
        let imgData = image.jpegData(compressionQuality: 0.2)!
        let URL = try! URLRequest(url: "\(kCJBaseUrl)api/index/upload", method: .post, headers: nil)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
          multipartFormData.append(imgData, withName: "file", fileName: "img.jpg", mimeType: "image/jpeg")
        }, with: URL) { (result) in
          switch result {
          case .success(let upload, _, _):
            upload.uploadProgress(closure: { (progress) in
              print("Upload Progress: \(progress.fractionCompleted)")
            })
            upload.responseJSON { response in
                if response.data != nil {
                    completion(JSON(response.data!), true)
                } else {
                    completion(nil, false)
                }
            }
          case .failure(let encodingError):
                completion(nil, false)
                print(encodingError)

          }
        }
    }
    
    /// 身份认证
    /// - Parameter idCard: 身份证正面
    /// - Parameter unidCard: 反面
    func authInfo(_ idCard: String, unidCard: String, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "idcardimg": idCard, "unidcardimg": unidCard] as [String : Any]
        self.POSTRequest(with: "index/info_auth", paramters: paramters, completion: completion)
    }
    
    /// 用户登录
    /// - Parameter phone: 手机号
    /// - Parameter pwd: 密码
    func userLogin(_ phone: String, pwd: String, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["type": 1, "phone": phone, "pwd": pwd] as [String : Any]
        self.POSTRequest(with: "index/login", paramters: paramters, completion: completion)
    }
    
    /// 苹果登陆
    /// - Parameter email: 邮箱
    func appleLogin(_ appleUser: String, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["type": 2, "openid": appleUser] as [String : Any]
        self.POSTRequest(with: "index/login", paramters: paramters, completion: completion)
    }
    
    /// 忘记密码
    /// - Parameter phone: 手机号
    /// - Parameter pwd: 密码
    /// - Parameter code: 验证码
    func forgetPwd(_ phone: String, pwd: String, code: String, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["phone": phone, "pwd": pwd, "code":code] as [String : Any]
        self.POSTRequest(with: "index/forget_pwd", paramters: paramters, completion: completion)
    }
    
    /// 访客列表
    func vistorList(_ completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId] as [String : Any]
        self.POSTRequest(with: "index/vistor_list", paramters: paramters, completion: completion)
    }
    
    /// 访客未读数量
    func vistorCount(_ completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId] as [String : Any]
        self.POSTRequest(with: "index/vistor_count", paramters: paramters, completion: completion)
    }
    
    /// 关注列表
    func followList(_ type: Int, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "type": type] as [String : Any]
        self.POSTRequest(with: "index/follow_list", paramters: paramters, completion: completion)
    }
    
    /// 用户信息  
    func userInfo(_ completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId] as [String : Any]
        self.POSTRequest(with: "index/user_info", paramters: paramters, completion: completion)
    }
    
    /// 城市列表
    func cityList(_ city: String = "0", completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["city_id": city]
        self.POSTRequest(with: "index/city_list", paramters: paramters, completion: completion)
    }
    
    /// 意见反馈
    /// - Parameters:
    ///   - text: 反馈内容
    func suggest(_ text: String, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "content": text] as [String : Any]
        self.POSTRequest(with: "index/add_feedback", paramters: paramters, completion: completion)
        
    }
    
    /// 帮助与引导
    func help(_ type: Int, completion: @escaping (_ response: RJResponse) -> Void) {
        var par: [String: String] = [:]
        if type == 1 {
            par = ["type": "question"]
        } else if type == 2 {
            par = ["type": "agreement"]
        } else if type == 3 {
            par = ["type": "convention"]
        } else if type == 4 {
            par = ["type": "about"]
        }
        self.POSTRequest(with: "index/agreement", paramters: par, completion: completion)
    }
    
    /// 首页
    /// - Parameters:
    ///   - page: 1
    func homeList(_ page: Int, heightStart: String? = nil, heightEnd: String? = nil, ageStart: String? = nil, ageEnd: String? = nil, city: Int? = nil, star: String? = nil, state: Int? = nil, video: Int? = nil, completion: @escaping (_ response: RJResponse) -> Void) {
        var paramters: [String: Any] = [:]
        if CurrentUser.sharedInstance.userId > 0 {
            paramters["uid"] = CurrentUser.sharedInstance.userId
        }
        if heightStart != nil && heightEnd != nil {
            paramters["height1"] = heightStart!
            paramters["height2"] = heightEnd!
        }
        if ageStart != nil && ageEnd != nil {
            paramters["age1"] = ageStart!
            paramters["age2"] = ageEnd!
        }
        if star != nil {
            paramters["constellation"] = star!
        }
        if city != nil {
            paramters["city_id"] = city!
        }
        if state != nil {
            paramters["state"] = state!
        }
        if video != nil {
            paramters["video_state"] = video!
        }
        paramters["sex"] = CurrentUser.sharedInstance.userSex == .boy ? 1 : 2
        paramters["page"] = page
        self.POSTRequest(with: "api/index", paramters: paramters, completion: completion)
    }
    
    /// 用户详情页面
    /// - Parameters:
    ///   - uid: 用户id
    func userDetail(_ uid: Int, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "see_uid": uid] as [String : Any]
        self.POSTRequest(with: "api/userDetail", paramters: paramters, completion: completion)
    }
    
    /// 用户动态列表
    /// - Parameter uid: 用户uid
    func userShows(_ uid: Int, page: Int, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "see_uid": uid, "page": page] as [String : Any]
        self.POSTRequest(with: "api/userShows", paramters: paramters, completion: completion)
    }
    
    /// 关注用户
    /// - Parameters:
    ///   - uid: 关注用户的 id
    func followUser(_ uid: Int,  completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "user_id": uid, "type": 1] as [String : Any]
        self.POSTRequest(with: "api/follow", paramters: paramters, completion: completion)
    }
    
    func blackUser(_ uid: Int,  completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "user_id": uid, "type": 2] as [String : Any]
        self.POSTRequest(with: "api/follow", paramters: paramters, completion: completion)
    }
    
    /// 动态列表
    /// - Parameters:
    ///   - type: 1-推荐  2-关注
    func societyList(_ type: Int = 1, page: Int = 1, completion: @escaping (_ response: RJResponse) -> Void) {
        var paramters = ["sex": (CurrentUser.sharedInstance.userSex == .boy ? 1 : 2), "type": type, "page": page] as [String : Any]
//        if !CurrentUser.isVisitor() {
            paramters["uid"] = CurrentUser.sharedInstance.userId
//        }                                                                                                                                                                                                                                                                                                                                                                   
        self.POSTRequest(with: "api/recShow", paramters: paramters, completion: completion)
    }
    
    /// 动态评论列表
    /// - Parameters:
    ///   - showId: 动态id
    func societyComList(_ showId: Int, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["show_id": showId] as [String : Any]
        self.POSTRequest(with: "api/showDetail", paramters: paramters, completion: completion)
    }
    
    /// 评论动态
    /// - Parameters:
    ///   - text: 内容
    ///   - showId: 动态id
    func commentSociety(content text: String, showId: Int, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "content": text, "show_id": showId] as [String : Any]
        self.POSTRequest(with: "api/comment", paramters: paramters, completion: completion)
    }
    
    /// 附近
    func nearbyList(_ page: Int = 1, heightStart: String? = nil, heightEnd: String? = nil, ageStart: String? = nil, ageEnd: String? = nil, city: Int? = nil, star: String? = nil, state: Int? = nil, video: Int? = nil, completion: @escaping (_ response: RJResponse) -> Void) {
        var paramters = ["uid": CurrentUser.sharedInstance.userId, "sex": (CurrentUser.sharedInstance.userSex == .boy ? 1 : 2), "city_id": CurrentUser.sharedInstance.city_id
            ] as [String : Any]
        
        if heightStart != nil && heightEnd != nil {
            paramters["height1"] = heightStart!
            paramters["height2"] = heightEnd!
        }
        if ageStart != nil && ageEnd != nil {
            paramters["age1"] = ageStart!
            paramters["age2"] = ageEnd!
        }
        if star != nil {
            paramters["constellation"] = star!
        }
        if city != nil {
            paramters["city_id2"] = city!
        }
        if state != nil {
            paramters["state"] = state!
        }
        if video != nil {
            paramters["video_state"] = video!
        }
        self.POSTRequest(with: "api/nearby", paramters: paramters, completion: completion)
    }
    
    /// 举报
    /// - Parameter uid: 举报用户id
    /// - Parameter reason: 原因
    /// - Parameter pic: 证据图片
    func report(with uid: Int, reason: String, pic: String?, completion: @escaping (_ response: RJResponse) -> Void) {
        var paramters = ["uid": CurrentUser.sharedInstance.userId, "user_id": uid, "reason": reason] as [String : Any]
        if pic != nil {
            paramters["evidence"] = pic!
        }
        self.POSTRequest(with: "api/tipoff", paramters: paramters, completion: completion)
    }
    
    func addShow(_ imgs: String, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "img": imgs] as [String : Any]
        self.POSTRequest(with: "index/add_show", paramters: paramters, completion: completion)
    }
    
    func applePay(_ type: Int, order: String, receipt: String, test: Bool, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "type": type, "ordernum": order, "receipt-data": receipt, "is_test": test ? 1 : 0] as [String : Any]
        self.POSTRequest(with: "api/apple_pay", paramters: paramters, completion: completion)
    }
    
    func fetchAuthInfo(_ completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId] as [String : Any]
        self.POSTRequest(with: "api/checkAuth", paramters: paramters, completion: completion)
    }
    
    /// 动态点赞
    func likeShow(_ showid: Int, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "show_id": showid] as [String : Any]
        self.POSTRequest(with: "api/like", paramters: paramters, completion: completion)
    }
    
    func authVideo(_ path: String, completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId, "video": path] as [String : Any]
        self.POSTRequest(with: "api/authVideo", paramters: paramters, completion: completion)
    }
    
    func sendMsg(to user: String, type: Int = 1, content: String) {
        let paramters = ["from_id": CurrentUser.sharedInstance.userId, "target_id": user, "chat_content": content, "type": type] as [String : Any]
        self.POSTRequest(with: "index/add_chat", paramters: paramters) { response in
            
        }
    }
    
    func blackList(_ completion: @escaping (_ response: RJResponse) -> Void) {
        let paramters = ["uid": CurrentUser.sharedInstance.userId] as [String : Any]
        self.POSTRequest(with: "api/blacklist", paramters: paramters, completion: completion)
    }
}
