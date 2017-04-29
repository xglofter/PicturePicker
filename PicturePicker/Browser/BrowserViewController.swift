//
//  BrowserViewController.swift
//  PicturePicker
//
//  Created by Richard on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

class BrowserViewController: UIViewController {

    var photos: [PhotoProtocol] = [PhotoProtocol]()
    var numberOfPhotos: Int {
        return photos.count
    }
    
    var initialPageIndex: Int = 0
    var currentPageIndex: Int = 0
    
    fileprivate var toolbar: BrowserToolbar!
    
    fileprivate lazy var pagingScrollView: PagingScrollView = PagingScrollView(frame: self.view.frame, browser: self)
    var backgroundView: UIView!

    // for status check property
    fileprivate var isEndAnimationByToolBar: Bool = true
    fileprivate var isViewActive: Bool = false
    fileprivate var isPerformingLayout: Bool = false
    
    fileprivate var isHiddenControls: Bool = false
    
    // pangesture property
    fileprivate var firstX: CGFloat = 0.0
    fileprivate var firstY: CGFloat = 0.0
    
    
    // MARK: - LifeCycle
    
    deinit {
        print("deinit BrowserViewController")
    }
    
    convenience init(photos: [PhotoProtocol]) {
        self.init(nibName: nil, bundle: nil)
        self.photos = photos
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAppearance()
        configureToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        reloadData()
        
        var i = 0
        for photo: PhotoProtocol in photos {
            photo.index = i
            i = i + 1
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        isPerformingLayout = true
        
        pagingScrollView.updateFrame(with: view.bounds, pageIndex: currentPageIndex)
        
        toolbar.frame = frameForToolbarAtOrientation()
        
        isPerformingLayout = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        isViewActive = true
    }

    override open var prefersStatusBarHidden: Bool {
        get {
            let currentOrientation = UIApplication.shared.statusBarOrientation
            if UIInterfaceOrientationIsLandscape(currentOrientation) {
                return true
            } else {
                return isHiddenControls   
            }
        }
    }
}

// MARK: - Public Founction

extension BrowserViewController {
    func initializePage(at index: Int) {
        var idx = index
        if index >= numberOfPhotos {
            idx = numberOfPhotos - 1
        }
        
        initialPageIndex = idx
        currentPageIndex = idx
        
        prepareNearPhoto()
    }
    
    func gotoPage(at index: Int) {
        if index < numberOfPhotos {
            if !isEndAnimationByToolBar {
                return
            }
            isEndAnimationByToolBar = false
            toolbar.updateToolbar(currentPageIndex)
            
            let pageFrame = frameForPage(at: index)
            pagingScrollView.animate(pageFrame)
        }
    }
    
    func gotoNextPage() {
        gotoPage(at: currentPageIndex + 1)
    }
    
    func gotoPreviousPage() {
        gotoPage(at: currentPageIndex - 1)
    }
    
    func tapSelectFlagView() {
        let number = PicturePicker.shared.getPhotoNumber(with: photos[currentPageIndex].asset.localIdentifier)
        if number == 0 { // 未被选中的图片
            if PicturePicker.shared.isMax {
                let alert = UIAlertController(title: nil, message: "todo message", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            PicturePicker.shared.choosePhoto(with: photos[currentPageIndex].asset)
            touch(with: PicturePicker.shared.currentNumber)
            
        } else { // 已被选中的图片
            PicturePicker.shared.unchoosePhoto(with: photos[currentPageIndex].asset.localIdentifier)
            touch(with: 0)
        }
    }
 
    func getIsControlsHidden() -> Bool {
        return (toolbar.alpha == 0.0)
    }
    
    func photo(at index: Int) -> PhotoProtocol {
        return photos[index]
    }
    
    func hideControls() {
        setControlsHidden(true, animated: true)
    }
    
    func toggleControls() {
        let hidden = !getIsControlsHidden()
        setControlsHidden(hidden, animated: true)
    }
    
    func reloadData() {
        performLayout()
        view.setNeedsLayout()
    }
    
    func prepareNearPhoto() {
        let nextIdx = currentPageIndex + 1
        let prevIdx = currentPageIndex - 1
        if nextIdx < numberOfPhotos {
            self.photos[nextIdx].fetchUnderlyingImage(completion: {})
        }
        if prevIdx >= 0 {
            self.photos[prevIdx].fetchUnderlyingImage(completion: {})
        }
        self.photos[currentPageIndex].fetchUnderlyingImage(completion: {})
    }
    
    func pageDisplayed(at index: Int) -> ZoomingScrollView? {
        return pagingScrollView.pageDisplayed(at: index)
    }
    
    func getImageFromView(_ sender: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(sender.frame.size, true, 0.0)
        sender.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    func touch(with number: Int) {
        toolbar.selectFlagView.text = String(format: "%d", number)
        if toolbar.selectFlagView.isSelected {
            toolbar.selectFlagView.isSelected = false
        } else {
            toolbar.selectFlagView.isSelected = true
            toolbar.selectFlagView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options:  [.curveEaseInOut], animations: {
                self.toolbar.selectFlagView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        }

    }
    
    func setFlag(isSelected: Bool, with number: Int) {
        if isSelected {
            toolbar.selectFlagView.isSelected = true
            toolbar.selectFlagView.text = String(format: "%d", number)
        } else {
            toolbar.selectFlagView.isSelected = false
        }
    }
}

// MARK: - Private Founction

private extension BrowserViewController {
    func configureAppearance() {
        view.backgroundColor = PickerConfig.browserBackgroundColor
        view.clipsToBounds = true
        view.isOpaque = false
        
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: PickerConstant.screenWidth, height: PickerConstant.screenHeight))
        backgroundView.backgroundColor = PickerConfig.browserBackgroundColor
        backgroundView.alpha = 1.0
        view.addSubview(backgroundView)
        
        pagingScrollView.delegate = self
        view.addSubview(pagingScrollView)
        
        // TODO: 在没有任何选中情况下，不能点击完成，或可添加当前已选图片个数提示
        let barItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(onFinishAction))
        navigationItem.rightBarButtonItem = barItem
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func configureToolbar() {
        toolbar = BrowserToolbar(frame: frameForToolbarAtOrientation(), browser: self)
        view.addSubview(toolbar)
    }
    
    @objc func onFinishAction() {
        self.dismiss(animated: true, completion: {
            PicturePicker.shared.endChoose(isFinish: true)
        })
    }
    
    func setControlsHidden(_ hidden: Bool, animated: Bool) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {

            let alpha: CGFloat = hidden ? 0.0 : 1.0
            self.toolbar.alpha = alpha
            self.toolbar.frame = hidden ? self.frameForToolbarHideAtOrientation() : self.frameForToolbarAtOrientation()
        }, completion: nil)
        
        self.navigationController?.setNavigationBarHidden(hidden, animated: true)

        self.isHiddenControls = hidden
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func frameForToolbarAtOrientation() -> CGRect {
        let currentOrientation = UIApplication.shared.statusBarOrientation
        var height: CGFloat = navigationController?.navigationBar.frame.size.height ?? 44
        if UIInterfaceOrientationIsLandscape(currentOrientation) {
            height = 32
        }
        return CGRect(x: 0, y: view.bounds.size.height - height, width: view.bounds.size.width, height: height)
    }
    
    func frameForToolbarHideAtOrientation() -> CGRect {
        let currentOrientation = UIApplication.shared.statusBarOrientation
        var height: CGFloat = navigationController?.navigationBar.frame.size.height ?? 44
        if UIInterfaceOrientationIsLandscape(currentOrientation) {
            height = 32
        }
        return CGRect(x: 0, y: view.bounds.size.height + 0, width: view.bounds.size.width, height: height)
    }
    
    func frameForPage(at index: Int) -> CGRect {
        let bounds = pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2 * 10)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + 10
        return pageFrame
    }
    
    func performLayout() {
        isPerformingLayout = true
        
        toolbar.updateToolbar(currentPageIndex)
        
        // reset local cache
        pagingScrollView.reload()
        
        // reframe
        pagingScrollView.updateContentOffset(at: currentPageIndex)
        pagingScrollView.tilePages()
        
        isPerformingLayout = false
    }
    
    func getSelectFlagFrame(isHidden: Bool) -> CGRect {
        var frame = CGRect.zero
        if isHidden {
            frame.origin = CGPoint(x: PickerConstant.screenWidth - 45, y: -20)
            frame.size = CGSize(width: 28, height: 28)
        } else {
            frame.origin = CGPoint(x: PickerConstant.screenWidth - 45, y: 95)
            frame.size = CGSize(width: 28, height: 28)
        }
        return frame
    }
}

// MARK: -  UIScrollView Delegate

extension BrowserViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isViewActive else {
            return
        }
        guard !isPerformingLayout else {
            return
        }
        
        // tile page
        pagingScrollView.tilePages()
        
        // Calculate current page
        let previousCurrentPage = currentPageIndex
        let visibleBounds = pagingScrollView.bounds
        currentPageIndex = min(max(Int(floor(visibleBounds.midX / visibleBounds.width)), 0), numberOfPhotos - 1)
        
        if currentPageIndex != previousCurrentPage {
            toolbar.updateToolbar(currentPageIndex)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
        isEndAnimationByToolBar = true
    }
}

