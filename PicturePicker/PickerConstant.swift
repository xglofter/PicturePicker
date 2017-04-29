//
//  PickerConstant.swift
//  PicturePicker
//
//  Created by guang xu on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

struct PickerConstant {
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    static var screenScale: CGFloat {
        return UIScreen.main.scale
    }
    static var screenRatio: CGFloat {
        return screenWidth / screenHeight
    }
}
