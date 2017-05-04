//
//  TapImageView.swift
//
//  Created by Richard on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

protocol TapImageViewDelegate: NSObjectProtocol {
    func handleImageViewSingleTap(at touchPoint: CGPoint)
    func handleImageViewDoubleTap(at touchPoint: CGPoint)
}

class TapImageView: UIImageView {
    weak var delegate: TapImageViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTap()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTap()
    }
    
    func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        delegate?.handleImageViewDoubleTap(at: recognizer.location(in: self))
    }
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        delegate?.handleImageViewSingleTap(at: recognizer.location(in: self))
    }
}

private extension TapImageView {
    func setupTap() {
        isUserInteractionEnabled = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.require(toFail: doubleTap)
        addGestureRecognizer(singleTap)
    }
}
