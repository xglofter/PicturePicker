//
//  PhotoToolbar.swift
//
//  Created by Richard on 2017/4/21.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

public protocol PhotoToolbarDelegate: NSObjectProtocol {
    func touchPreviewAction()
    func touchFinishAction()
}

open class PhotoToolbar: UIView {

    fileprivate(set) var topLineView: UIView!
    fileprivate(set) var previewButton: UIButton!
    fileprivate(set) var finishButton: UIButton!
    fileprivate(set) var contentLabel: UILabel!

    fileprivate let barHeight: CGFloat = PickerConfig.pickerToolbarHeight
    
    weak var delegate: PhotoToolbarDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setCurrentNumber(number: Int, maxNumber: Int) {
        let title = "已选择：\(number)/\(maxNumber)"
        contentLabel.text = title
        updateContentLabelFrame()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }
}


private extension PhotoToolbar {
    func setup() {
        self.backgroundColor = PickerConfig.pickerBackgroundColor
        
        topLineView = UIView()
        topLineView.backgroundColor = UIColor.lightGray
        self.addSubview(topLineView)
        
        previewButton = UIButton()
        previewButton.backgroundColor = PickerConfig.pickerThemeColor
        previewButton.setTitleColor(UIColor.white, for: .normal)
        previewButton.setTitle("预览", for: .normal)
        previewButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        previewButton.addTarget(self, action: #selector(onPreviewAction), for: .touchUpInside)
        previewButton.layer.cornerRadius = 4
        self.addSubview(previewButton)
        
        finishButton = UIButton()
        finishButton.backgroundColor = PickerConfig.pickerThemeColor
        finishButton.setTitleColor(UIColor.white, for: .normal)
        finishButton.setTitle("完成", for: .normal)
        finishButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        finishButton.addTarget(self, action: #selector(onFinishAction), for: .touchUpInside)
        finishButton.layer.cornerRadius = 4
        self.addSubview(finishButton)
        
        contentLabel = UILabel()
        contentLabel.textAlignment = .center
        contentLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentLabel.textColor = PickerConfig.pickerThemeColor
        self.addSubview(contentLabel)
    }
    
    func updateFrame() {
        topLineView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0.5)
        
        previewButton.frame.origin = CGPoint(x: 20, y: (bounds.height - 30)/2)
        previewButton.frame.size = CGSize(width: 50, height: 30)
        
        finishButton.frame.origin = CGPoint(x: bounds.width - 20 - 50, y: (bounds.height - 30)/2)
        finishButton.frame.size = CGSize(width: 50, height: 30)
        
        updateContentLabelFrame()
    }
    
    func updateContentLabelFrame() {
        contentLabel.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        contentLabel.frame.size = CGSize(width: 150, height: 30)
    }
    
    @objc func onPreviewAction() {
        self.delegate?.touchPreviewAction()
    }
    
    @objc func onFinishAction() {
        self.delegate?.touchFinishAction()
    }
}
