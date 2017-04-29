//
//  SelectFlagView.swift
//  PicturePicker
//
//  Created by Richard on 2017/4/21.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

class SelectFlagView: UILabel {

    var isSelected: Bool = false {
        didSet {
            if isSelected == false {
                self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.textColor = UIColor.clear
                self.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            } else {
                self.backgroundColor = PickerConfig.pickerThemeColor
                self.textColor = UIColor.white
                self.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.masksToBounds = true
        layer.borderWidth = 1
        textAlignment = .center
        font = UIFont.systemFont(ofSize: 15)
        
        // init state
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        textColor = UIColor.clear
        layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = layer.frame.width * 0.5
    }
    
}
