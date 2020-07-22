//
//  HelpGuideViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/23.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import WebKit
import RJNetworking_Swift

class HelpGuideViewController: RJViewController, WKNavigationDelegate {

    var type = 1
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let js = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta); var imgs = document.getElementsByTagName('img');for (var i in imgs){imgs[i].style.maxWidth='100%';imgs[i].style.height='auto';}"
        let wkScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUC = WKUserContentController()
        wkUC.addUserScript(wkScript)
        let wkConfig = WKWebViewConfiguration()
        wkConfig.userContentController = wkUC
        
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kNavigatioBarHeight), configuration: wkConfig)
        view.addSubview(webView)
        webView.navigationDelegate = self
        
        if type == 1 {
            title = "帮助与引导"
        } else if type == 2 {// 协议
            title = "注册协议"
        } else if type == 3 {// 公钥
            title = "注意事项"
        } else if type == 4 {
            title = "关于平台"
        }
         fetchHelpData()
    }
    
    private func fetchHelpData() {
        showProgressHUD()
        RJNetworking.CJNetworking().help(type) { (response) in
            if response.code == .Success {
                let content = response.response?["content"].stringValue ?? ""
                self.webView.loadHTMLString(content, baseURL: URL(string: kCJBaseUrl))
                self.hideProgressHUD()
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none';", completionHandler: nil)
        webView.evaluateJavaScript("document.activeElement.blur();", completionHandler: nil)
//        webView.evaluateJavaScript("document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '200%'", completionHandler: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
