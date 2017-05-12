//
//  AlbumTableViewCell.swift
//
//  Created by Richard on 2017/4/21.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit
import Photos

open class AlbumTableViewCell: UITableViewCell {
    public static let cellIdentity = "AlbumTableViewCell"
    
    fileprivate(set) var asset: PHAsset!
    fileprivate(set) var title: String!
    
    fileprivate(set) var previewImageView: UIImageView!
    fileprivate(set) var titleLabel: UILabel!
    fileprivate(set) var fileCountLabel: UILabel!
    fileprivate(set) var titleStackView: UIStackView!
    fileprivate(set) var bottomLine: UIView!
    
    fileprivate let previewWidth = PickerConfig.albumPreviewPhotoWidth
    fileprivate let previewHeight = PickerConfig.albumPreviewPhotoHeight
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }
    
    
}

// MARK: Internal Function

extension AlbumTableViewCell {
    func setAlbumPreview(asset: PHAsset?) {
        guard asset != nil else {
            return
        }
        
        let imgWidth = previewWidth
        let imgHeight = previewHeight
        let scale = PickerConstant.screenScale
        let defaultSize = CGSize(width: scale * imgWidth, height: scale * imgHeight)
        PHCachingImageManager.default().requestImage(for: asset!, targetSize: defaultSize, contentMode: .aspectFill, options: nil, resultHandler: { (img, _) in
            self.previewImageView.image = img
        })
    }
    
    func setAlbumTitle(title: String?, fileCount: Int) {
        titleLabel.text = title ?? ""
        fileCountLabel.text = "(\(fileCount))"
    }
}

// MARK: Private Function

private extension AlbumTableViewCell {
    func setup() {
        previewImageView = UIImageView()
        previewImageView.clipsToBounds = true
        previewImageView.contentMode = .scaleAspectFill
        addSubview(previewImageView)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = PickerConfig.albumFontColor
        addSubview(titleLabel)
        
        fileCountLabel = UILabel()
        fileCountLabel.font = UIFont.boldSystemFont(ofSize: 16)
        fileCountLabel.textColor = PickerConfig.albumFileCountFontColor
        addSubview(fileCountLabel)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = PickerConfig.formLineColor
        addSubview(bottomLine)
    }
    
    func updateFrame() {
        let marginH = (PickerConfig.albumCellHeight - previewHeight) / 2
        previewImageView.frame = CGRect(x: 15, y: marginH, width: previewWidth, height: previewHeight)
        
        let titleWidth = titleLabel.textRect(forBounds: bounds, limitedToNumberOfLines: 1).width
        let previewRight = previewImageView.frame.maxX
        titleLabel.frame = CGRect(x: previewRight + 15, y: 10, width: titleWidth, height: bounds.height - 20)
        
        let titleRight = titleLabel.frame.maxX
        let countWidth = fileCountLabel.textRect(forBounds: bounds, limitedToNumberOfLines: 1).width
        fileCountLabel.frame = CGRect(x: titleRight + 5, y: 10, width: countWidth, height: bounds.height - 20)
        
        let titleLeft = titleLabel.frame.minX
        let bottomLineWidth = bounds.width - titleLeft
        bottomLine.frame = CGRect(x: titleLeft, y: bounds.height - 0.5, width: bottomLineWidth, height: 0.5)
    }
}




