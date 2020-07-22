//
//  RJNetworking.swift

import UIKit
import Alamofire
import SwiftyJSON

public enum Code: Int {
    case Success = 200
    case Failed = 100
    case Error = -1
}

public struct RJResponse {
    public var code: Code
    public var response: JSON?
    public var message: String?
    
    init(code: Code = .Success, response: JSON? = nil, message: String? = nil) {
        self.code = code
        self.response = response
        self.message = message
    }
}

public final class RJNetworking {
    public static var KDEFAULT_BASEURL: String = "http://app.103101.com/Xiangjiao/"
    public static var KDEFAULT_ERRORMSG: String = "接口请求失败，请稍后再试~"
    
    
    public var kBaseUrl: String?
    
    public var codeKey: String = "code"
    public var successCode: Int = 200
    public var messageKey: String = "msg"
    public var responseKey: String?
    
    var reachAble: Bool = true
    
    public static let sharedInstance: RJNetworking = {
        let instance = RJNetworking()
        return instance
    }()
    
    init() {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        manager?.listener = {
            state in
            switch state {
            case .unknown:
                self.reachAble = false
            case .notReachable:
                self.reachAble = false
            case .reachable(.wwan):
                self.reachAble = true
            case .reachable(.ethernetOrWiFi):
                self.reachAble = true
            }
        }
        manager?.startListening()
    }
    
    public func GETRequest(with path: String, paramters: Parameters?, completion: @escaping (_ response: RJResponse) -> Void) {
        self.requestData(with: path, paramters: paramters, completion: completion)
    }
    
    public func POSTRequest(with path: String, paramters: Parameters?, completion: @escaping (_ response: RJResponse) -> Void) {
        self.requestData(with: path, method: .post, paramters: paramters, completion: completion)
    }
    
    fileprivate func requestData(with path:String, method: HTTPMethod = .get, paramters: Parameters? = nil, completion: @escaping (_ response: RJResponse) -> Void) -> Void {
        if self.reachAble == false {
            completion(RJResponse(code: .Error, response: nil, message: "当前网络不可用~"))
            return;
        }
        
        if kBaseUrl == nil {
            kBaseUrl = RJNetworking.KDEFAULT_BASEURL
        }
        let requestUrlString: String = kBaseUrl?.appending(path) ?? path
        Alamofire.request(requestUrlString, method: method,  parameters: paramters).responseJSON { [unowned self] (response) in
            var rjresponse: RJResponse = RJResponse()
            switch response.result {
                case .success(let json):
                    let swiftJson: JSON = JSON(json)
                    rjresponse.message = swiftJson[self.messageKey].string
                    if let resKey = self.responseKey {
                        rjresponse.response = swiftJson[resKey]
                        if let code = swiftJson[self.codeKey].int, code == self.successCode {
                            rjresponse.code = .Success
                        } else {
                            rjresponse.code = .Failed
                        }
                    } else {
                        rjresponse.code = .Success
                        rjresponse.response = swiftJson
                    }
                case .failure(let error):
                    rjresponse.code = .Error
                    rjresponse.message = RJNetworking.KDEFAULT_ERRORMSG
                    debugPrint(error)
            }
            debugPrint("*************-START-*************")
            debugPrint("path: \(requestUrlString)")
            if paramters != nil {
                debugPrint("paramters: \(String(describing: paramters))")
            }
            debugPrint("response: \(response)")
            debugPrint("*************-END-*************")
            completion(rjresponse)
        }
    }
    
}



