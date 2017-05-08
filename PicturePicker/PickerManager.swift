//
//  PickerManager.swift
//
//  Created by Richard on 2017/4/20.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit
import Photos

public class PickerManager: NSObject {
    public static let shared = PickerManager()
    
    public typealias ChoosePhotosHandle = ([UIImage]) -> Void
    
    fileprivate(set) var callbackAfterFinish: ChoosePhotosHandle?
    fileprivate(set) var maxPhotos: Int = 0
    fileprivate(set) lazy var choosedAssets = [PHAsset]()
    fileprivate(set) lazy var fetchOutputImages = [UIImage]()
    
    /// 获取当前已选择图片的数目
    public var currentNumber: Int {
        get {
            return choosedAssets.count
        }
    }
    
    /// 当前是否已经选满了
    public var isMax: Bool {
        get {
            return choosedAssets.count == maxPhotos
        }
    }

    private override init() {
        super.init()
    }
    
    /// 开始选择图片
    ///
    /// - Parameters:
    ///   - number: 选择图片的最大数目
    ///   - handle: 回调处理
    public func startChoosePhotos(with number: Int, completion handle: @escaping ChoosePhotosHandle) {
        
        guard number > 0 && number < 100 else {
            fatalError("choosePhotos with unexpected number.")
        }
        
        resetPicker()
        maxPhotos = number
        callbackAfterFinish = handle
        
        let library: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if library == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                print("permission", status.rawValue)
                if status == PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async { [weak self] _ in
                        self?.presentPicker()
                    }
                }
            }
        } else if library == .denied || library == .restricted {
            let alert = UIAlertController(title: nil, message: "需要访问您的相册，请前往设置打开权限", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(okAction)
            topMostViewController()?.present(alert, animated: true, completion: nil)
        } else {
            presentPicker()
        }
    }
    
    /// 终止选择图片
    ///
    /// - Parameter isFinish: 是否是完成了，false表示取消
    public func endChoose(isFinish: Bool) {
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
    public func getPhotoNumber(with id: String) -> Int {
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
    public func choosePhoto(with asset: PHAsset) {
        choosedAssets.append(asset)
    }
    
    /// 取消选择某图片
    ///
    /// - Parameter id: 图片 identity
    public func unchoosePhoto(with id: String) {
        let number = getPhotoNumber(with: id)
        if number != 0 {
            choosedAssets.remove(at: number - 1)
        } else {
            fatalError("错误！")
        }
    }
    
    /// 重置 PickerManager 参数
    public func resetPicker() {
        choosedAssets.removeAll()
        maxPhotos = 0
        callbackAfterFinish = nil
        fetchOutputImages.removeAll()
    }
}

// MARK: - Private Function

private extension PickerManager {
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

