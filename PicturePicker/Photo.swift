//
//  Photo.swift
//
//  Created by Richard on 2017/4/27.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit
import Photos

public protocol PhotoProtocol: NSObjectProtocol {
    var underlyingImage: UIImage! { get }
    var originImage: UIImage! { get set }
    var index: Int { get set }
    var asset: PHAsset! { get }
    
    func fetchUnderlyingImage(completion: @escaping () -> ())
    func fetchOriginImage(completion: @escaping () -> ())
}

// MARK: - Photo

open class Photo: NSObject, PhotoProtocol {
    
    public var underlyingImage: UIImage!
    public var originImage: UIImage!
    public var index: Int = 0
    public var asset: PHAsset!
    
    lazy var manager = PHCachingImageManager()
    
    var fetchImageReqID: PHImageRequestID!
    var fetchOriginReqID: PHImageRequestID!
    
    override init() {
        super.init()
    }
    
    convenience init(asset: PHAsset) {
        self.init()
        self.asset = asset
    }
    
    public func fetchUnderlyingImage(completion: @escaping () -> ()) {
        if underlyingImage != nil {
            return
        }
        let scale = PickerConstant.screenScale
        let size = CGSize(width: 80 * scale, height: 80 * scale)

        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .default, options: nil) { (image, _) in
            self.underlyingImage = image
            completion()
        }
    }
    
    public func fetchOriginImage(completion: @escaping () -> ()) {
        if originImage != nil || fetchOriginReqID != nil {
            return
        }
        
        let scale = PickerConstant.screenScale
        let size = CGSize(width: 480 * scale, height: 480 * scale)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .default, options: options) { (image, _) in
            self.originImage = image
            completion()
        }
    }
}

