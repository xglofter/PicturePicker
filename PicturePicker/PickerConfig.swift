//
//  PickerConfig.swift
//
//  Created by guang xu on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

public struct PickerConfig {
    public static var pickerBackgroundColor: UIColor = UIColor.white
    public static var pickerThemeColor: UIColor = UIColor.orange.withAlphaComponent(0.5)
    public static var albumFontColor: UIColor = UIColor.black
    public static var albumFileCountFontColor: UIColor = UIColor.lightGray
    public static var formLineColor: UIColor = UIColor(red: 226/255, green: 229/255, blue: 231/255, alpha: 1)
    public static var pickerToolbarColor: UIColor = UIColor.orange.withAlphaComponent(0.5)
    
    public static var albumCellHeight: CGFloat = 62
    public static var albumPreviewPhotoWidth: CGFloat = 60
    public static var albumPreviewPhotoHeight: CGFloat = 60
    
    public static var pickerToolbarHeight: CGFloat = 45
    
    public static var browserBackgroundColor: UIColor = UIColor.black
    public static var browserToolbarColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    
    public static var browserShowHorizontalScrollIndicator: Bool = true
    public static var browserShowVerticalScrollIndicator: Bool = true
    
    public static var browserShowToolbar: Bool = true
    
    public static var browserEnableZoomBlackArea: Bool = true
}
