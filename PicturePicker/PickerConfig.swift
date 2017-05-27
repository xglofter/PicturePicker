//
//  PickerConfig.swift
//
//  Created by guang xu on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

public struct PickerConfig {
    public static var pickerThemeColor = UIColor(red: 99/255, green: 184/255, blue: 255/255, alpha: 0.9)
    public static var pickerBackgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
    public static var albumFontColor = UIColor.black
    public static var albumFileCountFontColor = UIColor.lightGray
    public static var formLineColor = UIColor(red: 226/255, green: 229/255, blue: 231/255, alpha: 1)
    public static var pickerToolbarColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
    
    public static var albumCellHeight: CGFloat = 62
    public static var albumPreviewPhotoWidth: CGFloat = 60
    public static var albumPreviewPhotoHeight: CGFloat = 60
    
    public static var pickerToolbarHeight: CGFloat = 45
    public static var pickerToolbarLabelColor: UIColor = UIColor.black
    
    public static var browserBackgroundColor: UIColor = UIColor.black
    public static var browserToolbarColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    
    public static var browserShowHorizontalScrollIndicator: Bool = true
    public static var browserShowVerticalScrollIndicator: Bool = true
    
    public static var browserShowToolbar: Bool = true
    
    public static var browserEnableZoomBlackArea: Bool = true
}
