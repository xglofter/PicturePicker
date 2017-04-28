//
//  AlbumTableViewController.swift
//  Stitcher
//
//  Created by Richard on 2017/4/20.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit
import Photos

class AlbumTableViewController: UITableViewController {

    deinit {
        print("deinit AlbumTableViewController")
    }
    
    enum AlbumSection: Int {
        case allPhotos = 0
        case otherAlbumPhotos
        
        static let count = 2
    }
    
    fileprivate(set) var allPhotos: PHFetchResult<PHAsset>!
    fileprivate(set) lazy var otherAlbumTitles = [String]()
    fileprivate(set) lazy var otherAlbumPhotos = [PHFetchResult<PHAsset>]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        fetchAlbums()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return AlbumSection.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AlbumSection(rawValue: section)! {
        case .allPhotos:
            return 1
        case .otherAlbumPhotos:
            return otherAlbumPhotos.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PickerConfig.albumCellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumTableViewCell", for: indexPath) as! AlbumTableViewCell
        cell.accessoryType = .disclosureIndicator
        
        switch AlbumSection(rawValue: indexPath.section)! {
        case .allPhotos:
            cell.setAlbumPreview(asset: allPhotos.firstObject)
            cell.setAlbumTitle(title: "所有照片", fileCount: allPhotos.count)
        case .otherAlbumPhotos:
            let photoAssets = otherAlbumPhotos[indexPath.row]
            let asset = photoAssets.firstObject
            cell.setAlbumPreview(asset: asset)
            cell.setAlbumTitle(title: otherAlbumTitles[indexPath.row], fileCount: photoAssets.count)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch AlbumSection.init(rawValue: indexPath.section)! {
        case .allPhotos:
            print("")
            let gridVC = PhotosGridViewController(with: allPhotos)
            gridVC.title = "所有照片"
            self.navigationController?.pushViewController(gridVC, animated: true)
        case .otherAlbumPhotos:
            print("")
            let gridVC = PhotosGridViewController(with: otherAlbumPhotos[indexPath.row])
            gridVC.title = otherAlbumTitles[indexPath.row]
            self.navigationController?.pushViewController(gridVC, animated: true)
        }
    }
}


// MARK: Private Function

private extension AlbumTableViewController {
    func setup() {
        navigationItem.title = "照片"
        
        self.view.backgroundColor = PickerConfig.pickerBackgroundColor
        
        let cancelTitle = "取消"
        let barItem = UIBarButtonItem(title: cancelTitle, style: .plain, target: self, action: #selector(onDismissAction))
        navigationItem.rightBarButtonItem = barItem
    }
    
    @objc func onDismissAction() {
        print("onDismissAction")
        
        self.dismiss(animated: true, completion: {
            PicturePicker.shared.endChoose(isCancel: true)
        })
    }
    
    func fetchAlbums() {
        
        let allPhotoOptions = PHFetchOptions()
        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotoOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        allPhotos = PHAsset.fetchAssets(with: allPhotoOptions)
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        func getAlbumNotEmpty(from albums: PHFetchResult<PHAssetCollection>) {
            let photoOptions = PHFetchOptions()
            photoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            for index in 0 ..< albums.count {
                let collection = albums.object(at: index)
                let asset = PHAsset.fetchAssets(in: collection, options: photoOptions)
                if asset.count != 0 {
                    self.otherAlbumTitles.append(collection.localizedTitle ?? "")
                    self.otherAlbumPhotos.append(asset)
                }
            }
        }
        getAlbumNotEmpty(from: smartAlbums)
        getAlbumNotEmpty(from: userCollections as! PHFetchResult<PHAssetCollection>)
        print(otherAlbumPhotos.count)
        
        
        // 监测系统相册增加
        // PHPhotoLibrary.shared().register(self) // TODO
        
        // 注册cell
        tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: AlbumTableViewCell.cellIdentity)
        tableView.separatorStyle = .none
    }
}

