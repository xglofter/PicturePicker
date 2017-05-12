//
//  TapView.swift
//
//  Created by Richard on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

public protocol TapViewDelegate: NSObjectProtocol {
    func handleTapViewSingleTap(from view: UIView, touch: UITouch)
    func handleTapViewDoubleTap(from view: UIView, touch: UITouch)
}

open class TapView: UIView {
    weak var delegate: TapViewDelegate?
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        defer {
            _ = next
        }
        
        guard let touch = touches.first else {
            return
        }
        switch touch.tapCount {
        case 1: handleSingleTap(touch)
        case 2: handleDoubleTap(touch)
        default: break
        }
    }
    
    func handleSingleTap(_ touch: UITouch) {
        delegate?.handleTapViewSingleTap(from: self, touch: touch)
    }
    
    func handleDoubleTap(_ touch: UITouch) {
        delegate?.handleTapViewDoubleTap(from: self, touch: touch)
    }
}

