//
//  RJBackgroundButton.swift
//  SwiftApp
import UIKit

class RJBackgroundButton: UIButton {
    var normalColor: UIColor = UIColor.white
    var touchColor: UIColor = .lightGray
    
    var touched: Bool = false {
        didSet {
            if touched {
                if self.currentTitle == "男生" || self.currentTitle == "女生" {
                    self.setTitleColor(.white, for: .normal)
                }
                self.backgroundColor = touchColor
            } else {
                if self.currentTitle == "男生" || self.currentTitle == "女生" {
                    self.setTitleColor(.lightGray, for: .normal)
                }
                self.backgroundColor = normalColor
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.borderColor = UIColor.black.cgColor
            } else {
                self.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
    }
    
    static func button(title: String?, cornerRadius: CGFloat? = 0) -> RJBackgroundButton {
        let btn = RJBackgroundButton(type: .custom)
        btn.addButtonAction()
        return btn
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addButtonAction()
    }
    
    func addButtonAction() {
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchUpOut), for: .touchUpOutside)
    }
    
    @objc func touchDown() {
        self.touched = true
    }
    @objc func touchUpOut() {
        self.touched = false
    }
}
