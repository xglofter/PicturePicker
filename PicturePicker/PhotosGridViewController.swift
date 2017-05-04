//
//  PhotosGridViewController.swift
//
//  Created by Richard on 2017/4/20.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit
import Photos

class PhotosGridViewController: UIViewController {
    
    var photoAssets: PHFetchResult<PHAsset>!
    
    var collectionView: UICollectionView!
    var toolBar: PhotoToolbar!
    
    let numberOneRow: CGFloat = 4  // 每行放置4个Cell, TODO：改为固定值，或者旋转以后可以调整
    let spaceOnCell: CGFloat = 4
    
    /// 带缓存的图片管理对象
    var imageManager: PHCachingImageManager!
    
    fileprivate var toolBarIsHidden: Bool = true
    
    // MARK: - Lifecycle
    
    deinit {
        print("deinit PhotosGridViewController")
        self.resetCachedAssets()
    }
    
    init(with photoAssets: PHFetchResult<PHAsset>) {
        super.init(nibName: nil, bundle: nil)
        self.photoAssets = photoAssets
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setup()
        setupFrame()
        
        self.imageManager = PHCachingImageManager()
        self.imageManager.allowsCachingHighQualityImages = false
        self.resetCachedAssets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkBarShouldHidden()
        changeVisibleFlag()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateSubviewsFrame(to: size)
    }
}

extension PhotosGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identify = PhotoCollectionViewCell.cellIdentity
        let cell = self.collectionView!.dequeueReusableCell(withReuseIdentifier: identify, for: indexPath) as! PhotoCollectionViewCell
        
        let asset = self.photoAssets[indexPath.row]
        cell.asset = asset
        
        // 获取 flag
        let number = PickerManager.shared.getPhotoNumber(with: asset.localIdentifier)
        cell.setFlag(isSelected: (number != 0), with: number)
        
        // 点击 flag 回调处理
        cell.flagCallback = { [weak self] in

            let number = PickerManager.shared.getPhotoNumber(with: cell.asset.localIdentifier)
            if number == 0 { // 未被选中的图片
                if PickerManager.shared.isMax {
                    self?.alert(with: "您最多只能选\(PickerManager.shared.maxPhotos)张")
                    return
                }
                
                PickerManager.shared.choosePhoto(with: cell.asset)
                cell.touch(with: PickerManager.shared.currentNumber)
                
            } else { // 已被选中的图片
                PickerManager.shared.unchoosePhoto(with: cell.asset.localIdentifier)
                cell.touch(with: 0)
                
                DispatchQueue.main.async {
                    self?.changeVisibleFlag()
                }
            }
            
            self?.checkBarShouldHidden()
        }
        
        // 获取缩略图
        let size = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        let scale = PickerConstant.screenScale
        let theSize = CGSize(width: scale * size.width, height: scale * size.height)
        self.imageManager.requestImage(for: asset,
                                       targetSize: theSize,
                                       contentMode: PHImageContentMode.aspectFill,
                                       options: nil)
        { (image, _) in
            if cell.asset.localIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        }

        return cell
    }
}

extension PhotosGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("======= touch at ===========")
        let myAsset = self.photoAssets[indexPath.row]
        print(myAsset.description)
        print("============================")
        
        presentBrowser(index: indexPath.row)
    }
}

// MARK: - PhotoToolbarDelegate 

extension PhotosGridViewController: PhotoToolbarDelegate {
    func touchPreviewAction() {
        presentBrowser(index: 0)
    }
    
    func touchFinishAction() {
        self.dismiss(animated: true, completion: {
            PickerManager.shared.endChoose(isFinish: true)
        })
    }
}

// MARK: - Private Function

private extension PhotosGridViewController {
    
    func setup() {
        self.view.backgroundColor = PickerConfig.pickerBackgroundColor
        
        let barItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(onDismissAction))
        navigationItem.rightBarButtonItem = barItem
        
        let layout = UICollectionViewFlowLayout()
        let cellWidth = (view.bounds.width - (numberOneRow - 1) * spaceOnCell) / numberOneRow
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        layout.minimumInteritemSpacing = spaceOnCell
        layout.minimumLineSpacing = spaceOnCell
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = PickerConfig.pickerBackgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        
        toolBar = PhotoToolbar()
        toolBar.delegate = self
        self.view.addSubview(toolBar)
        
        let identity = PhotoCollectionViewCell.cellIdentity
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: identity)
    }
    
    func setupFrame() {
        collectionView.frame = view.bounds
        toolBar.frame = CGRect(x: 0,
                               y: view.bounds.height,
                               width: view.bounds.width,
                               height: PickerConfig.pickerToolbarHeight)
    }
    
    func updateFrame(isHideBar: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            if isHideBar {
                self.collectionView.frame.size.height = self.view.bounds.height
                self.toolBar.frame.origin.y = self.view.bounds.height
            } else {
                self.collectionView.frame.size.height = self.view.bounds.height - PickerConfig.pickerToolbarHeight
                self.toolBar.frame.origin.y = self.view.bounds.height - PickerConfig.pickerToolbarHeight
            }
        }, completion: { _ in
            self.toolBarIsHidden = isHideBar
        })
    }
    
    func updateSubviewsFrame(to size: CGSize) {
        if toolBarIsHidden {
            collectionView.frame.size = size
            toolBar.frame = CGRect(x: 0,
                                   y: size.height,
                                   width: size.width,
                                   height: PickerConfig.pickerToolbarHeight)
        } else {
            collectionView.frame = CGRect(x: 0,
                                          y: 0,
                                          width: size.width,
                                          height: size.height - PickerConfig.pickerToolbarHeight)
            toolBar.frame = CGRect(x: 0,
                                   y: size.height - PickerConfig.pickerToolbarHeight,
                                   width: size.width,
                                   height: PickerConfig.pickerToolbarHeight)
        }
    }
    
    //重置缓存
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
    }
    
    func checkBarShouldHidden() {
        let number = PickerManager.shared.currentNumber
        if number == 0 { // 未有任何图片选中过
            if toolBarIsHidden == false {
                updateFrame(isHideBar: true)
            }
        } else { // 有选中了
            if toolBarIsHidden == true {
                updateFrame(isHideBar: false)
            }
        }
        toolBar.setCurrentNumber(number: number, maxNumber: PickerManager.shared.maxPhotos)
    }
    
    func changeVisibleFlag() {
        let indexPaths = self.collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                let number = PickerManager.shared.getPhotoNumber(with: cell.asset.localIdentifier)
                cell.setFlag(isSelected: (number != 0), with: number)
            }
        }
    }
    
    func presentBrowser(index: Int) {
        var photoArray = [PhotoProtocol]()
        for i in 0..<self.photoAssets.count {
            photoArray.append(Photo(asset: self.photoAssets[i]))
        }
        let browser = BrowserViewController(photos: photoArray)
        browser.initializePage(at: index)
        navigationController?.pushViewController(browser, animated: true)
    }
    
    func alert(with message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Callback methods
    
    @objc func onDismissAction() {
        self.dismiss(animated: true, completion: {
            PickerManager.shared.endChoose(isFinish: false)
        })
    }
}
