//
//  PicturePicker.swift
//  Stitcher
//
//  Created by Richard on 2017/4/20.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit
import Photos

class PicturePicker: NSObject {
    static let shared = PicturePicker()
    
    typealias ChoosePhotosHandle = ([UIImage]) -> Void
    fileprivate(set) var callbackAfterFinish: ChoosePhotosHandle?
    
    fileprivate(set) var maxPhotos: Int = 0
    
    /// 获取当前已选择图片的数目
    var currentNumber: Int {
        get {
            return choosedAssets.count
        }
    }
    
    /// 当前是否已经选满了
    var isMax: Bool {
        get {
            return choosedAssets.count == maxPhotos
        }
    }
    
    fileprivate(set) lazy var choosedAssets = [PHAsset]()
    fileprivate(set) lazy var fetchOutputImages = [UIImage]()
    
    private override init() {
        super.init()
    }
    
    /// 开始选择图片
    ///
    /// - Parameters:
    ///   - number: 选择图片的最大数目
    ///   - handle: 回调处理
    func startChoosePhotos(with number: Int, completion handle: @escaping ChoosePhotosHandle) {
        
        guard number > 0 && number < 100 else {
            fatalError("choosePhotos with unexpected number.")
        }
        
        resetPicker()
        
        maxPhotos = number
        callbackAfterFinish = handle
        
        presentPicker()
    }
    
    /// 终止选择图片
    ///
    /// - Parameter isFinish: 是否是完成了，false表示取消
    func endChoose(isFinish: Bool) {
        if isFinish {
            for asset in choosedAssets {
                PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: nil, resultHandler: { (img, _) in
                    self.callbackAfterFetch(img: img!)
                })
            }
        } else {
            resetPicker()
        }
    }
    
    /// 获取某图片的 flag 数字
    ///
    /// - Returns: 0 表示未被选择，1 ~ maxPhotos 已被选择的序列号
    func getPhotoNumber(with id: String) -> Int {
        var idx = 1
        for asset in choosedAssets {
            if asset.localIdentifier == id {
                return idx
            }
            idx += 1
        }
        return 0
    }
    
    /// 选择某图片
    ///
    /// - Parameter asset: 图片 PHAsset 资源
    func choosePhoto(with asset: PHAsset) {
        choosedAssets.append(asset)
    }
    
    /// 取消选择某图片
    ///
    /// - Parameter id: 图片 identity
    func unchoosePhoto(with id: String) {
        let number = getPhotoNumber(with: id)
        if number != 0 {
            choosedAssets.remove(at: number - 1)
        } else {
            fatalError("错误！")
        }
    }
    
    /// 重置 PicturePicker 参数
    func resetPicker() {
        choosedAssets.removeAll()
        maxPhotos = 0
        callbackAfterFinish = nil
        fetchOutputImages.removeAll()
    }
}

private extension PicturePicker {
    func callbackAfterFetch(img: UIImage) {
        fetchOutputImages.append(img)
        if fetchOutputImages.count == choosedAssets.count {
            callbackAfterFinish?(fetchOutputImages)
        }
    }
    
    func presentPicker() {
        let albumVC = AlbumTableViewController()
        let naviVC = UINavigationController(rootViewController: albumVC)
        topMostViewController()?.present(naviVC, animated: true, completion: nil)
    }
    
    func topMostViewController() -> UIViewController? {
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
}
