//
//  PickerConfig.swift
//  PicturePicker
//
//  Created by guang xu on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

struct PickerConfig {
    static var pickerBackgroundColor: UIColor = UIColor.white
    static var pickerThemeColor: UIColor = UIColor.orange.withAlphaComponent(0.5)
    static var albumFontColor: UIColor = UIColor.black
    static var albumFileCountFontColor: UIColor = UIColor.lightGray
    static var formLineColor: UIColor = UIColor(red: 226/255, green: 229/255, blue: 231/255, alpha: 1)
    static var pickerToolbarColor: UIColor = UIColor.orange.withAlphaComponent(0.5)
    
    static var albumCellHeight: CGFloat = 62
    static var albumPreviewPhotoWidth: CGFloat = 60
    static var albumPreviewPhotoHeight: CGFloat = 60
    
    static var pickerToolbarHeight: CGFloat = 45
    
    static var browserBackgroundColor: UIColor = UIColor.black
    static var browserToolbarColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    
    static var browserShowHorizontalScrollIndicator: Bool = true
    static var browserShowVerticalScrollIndicator: Bool = true
    
    static var browserShowToolbar: Bool = true
    static var browserShowStatusbar: Bool = false
    
    static var browserEnableZoomBlackArea: Bool = true
}
