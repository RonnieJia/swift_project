//
//  RJViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/3/11.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class RJViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ViewControllerBackgroundColor()
        setUpBackBarItem()
    }
    
    func setUpBackBarItem() {
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = .black;
        let image = UIImage(named: "back001")
        self.navigationController?.navigationBar.backIndicatorImage = image;
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = image;
        self.navigationItem.backBarButtonItem = backItem;
    }
    
    func adjustsScrollViewInsets(_ scrollView: UIScrollView) {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let path = Bundle.main.path(forResource: "NavigationBarHidden", ofType: "plist") ?? ""
        var hidden = false
        if let arr = NSArray(contentsOfFile: path) as? [String] {
            let cls = self.className
            if arr.contains(cls) {
                hidden = true
            }
        }
        if hidden {
            if !(navigationController?.isNavigationBarHidden ?? true) {
                navigationController?.setNavigationBarHidden(hidden, animated: animated)
            }
        } else {
            if navigationController?.isNavigationBarHidden ?? true {
                navigationController?.setNavigationBarHidden(hidden, animated: animated)
            }
        }
    }

}

