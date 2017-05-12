//
//  PickerConstant.swift
//
//  Created by guang xu on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

public struct PickerConstant {
    public static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    public static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    public static var screenScale: CGFloat {
        return UIScreen.main.scale
    }
    public static var screenRatio: CGFloat {
        return screenWidth / screenHeight
    }
}
