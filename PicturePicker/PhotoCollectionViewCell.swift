//
//  PhotoCollectionViewCell.swift
//
//  Created by Richard on 2017/4/21.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionViewCell : UICollectionViewCell {
    static let cellIdentity = "PhotoCollectionViewCell"
    
    var asset: PHAsset!
    var flagCallback: (() -> Void)!
    
    fileprivate(set) var imageView: UIImageView!
    fileprivate(set) var imageViewMask: UIView!
    fileprivate(set) var flagView: SelectFlagView!
    fileprivate(set) var flagTouchView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }
}

// MARK: - Internal Function

internal extension PhotoCollectionViewCell {
    func touch(with number: Int) {
        self.flagView.text = String(format: "%d", number)
        if self.flagView.isSelected {
            self.flagView.isSelected = false
            self.imageViewMask.isHidden = true
        } else {
            self.flagView.isSelected = true
            self.flagView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.imageViewMask.isHidden = false
            self.imageViewMask.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options:  [.curveEaseInOut], animations: {
                self.flagView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
            UIView.animate(withDuration: 0.2, animations: {
                self.imageViewMask.alpha = 0.5
            })
        }
    }
    
    func setFlag(isSelected: Bool, with number: Int) {
        if isSelected {
            self.flagView.isSelected = true
            self.flagView.text = String(format: "%d", number)
            self.imageViewMask.isHidden = false
        } else {
            self.flagView.isSelected = false
            self.imageViewMask.isHidden = true
        }
    }
}

// MARK: - Private Function

private extension PhotoCollectionViewCell {
    func setup() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        imageViewMask = UIView()
        imageViewMask.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        imageViewMask.isHidden = true
        self.addSubview(imageViewMask)
        
        flagView = SelectFlagView()
        self.addSubview(flagView)
        
        flagTouchView = UIView()
        flagTouchView.backgroundColor = UIColor.clear
        flagTouchView.isUserInteractionEnabled = true
        self.addSubview(flagTouchView)
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(onTapFlagAction))
        flagTouchView.addGestureRecognizer(tapGes)
        
    }
    
    func updateFrame() {
        
        imageView.frame = bounds
        imageViewMask.frame = bounds
        
        let flagViewMarginWidth = CGFloat(5)
        let flagViewWidth = CGFloat(23)
        let flagViewLeft = bounds.width - flagViewWidth - flagViewMarginWidth
        flagView.frame = CGRect(x: flagViewLeft, y: flagViewMarginWidth, width: flagViewWidth, height: flagViewWidth)
        
        let flagTouchViewWidth = CGFloat(38)
        let flagTouchViewLeft = bounds.width - flagTouchViewWidth
        flagTouchView.frame = CGRect(x: flagTouchViewLeft, y: 0, width: flagTouchViewWidth, height: flagTouchViewWidth)
    }
    
    @objc func onTapFlagAction() {
        print("0000000000000")
        flagCallback()
    }
}


