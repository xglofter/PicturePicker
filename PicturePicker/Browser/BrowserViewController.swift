//
//  BrowserViewController.swift
//  PicturePicker
//
//  Created by guang xu on 2017/4/25.
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
    
    fileprivate var closeButton: BrowserCloseButton!
    fileprivate var chooseFlagView: SelectFlagView!
    fileprivate var toolbar: BrowserToolbar!
    
    fileprivate lazy var pagingScrollView: PagingScrollView = PagingScrollView(frame: self.view.frame, browser: self)
    var backgroundView: UIView!

    fileprivate var applicationWindow: UIWindow!
//    fileprivate var panGesture: UIPanGestureRecognizer!

    // for status check property
    fileprivate var isEndAnimationByToolBar: Bool = true
    fileprivate var isViewActive: Bool = false
    fileprivate var isPerformingLayout: Bool = false
    
    // pangesture property
    fileprivate var firstX: CGFloat = 0.0
    fileprivate var firstY: CGFloat = 0.0
    
    var fetchOriginTimer: Timer!
    
    // MARK: - LifeCycle
    
    convenience init(photos: [PhotoProtocol]) {
        self.init(nibName: nil, bundle: nil)
        self.photos = photos
        present()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAppearance()
        configureCloseButton()
        configureSelectButton()
        configureToolbar()
        
        presentAnimation()
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
        
//        startFetchOriginImage()
    }

    override open var prefersStatusBarHidden: Bool {
        get {
            return !PickerConfig.browserShowStatusbar
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

    func dismissPhotoBrowser(animated: Bool) {
        if !animated {
            modalTransitionStyle = .crossDissolve
        }
        dismiss(animated: animated, completion: nil)
    }
    
    func determineAndClose() {
        dismissAnimation()
    }
    
    func updateCloseButton(_ image: UIImage, size: CGSize? = nil) {
        if closeButton == nil {
            configureCloseButton()
        }
        closeButton.setImage(image, for: UIControlState())
        
        if let size = size {
            closeButton.setFrameSize(size)
        }
    }
    
    func showButtons() {
        closeButton.alpha = 1
        closeButton.frame = closeButton.showFrame
        
        chooseFlagView.alpha = 1
        chooseFlagView.frame = getSelectFlagFrame(isHidden: false)
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
    
}

// MARK: - Private Founction

private extension BrowserViewController {
    func present() {
        if let window = UIApplication.shared.delegate?.window {
            applicationWindow = window
        } else if let window = UIApplication.shared.keyWindow {
            applicationWindow = window
        } else {
            return
        }
        
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }

    func configureAppearance() {
        view.backgroundColor = PickerConfig.browserBackgroundColor
        view.clipsToBounds = true
        view.isOpaque = false
        
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: PickerConstant.screenWidth, height: PickerConstant.screenHeight))
        backgroundView.backgroundColor = PickerConfig.browserBackgroundColor
        backgroundView.alpha = 0.0
        applicationWindow.addSubview(backgroundView)
        
        pagingScrollView.delegate = self
        view.addSubview(pagingScrollView)
    }
    
    func configureCloseButton() {
        closeButton = BrowserCloseButton(frame: .zero)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        view.addSubview(closeButton)
    }
    
    func configureSelectButton() {
        chooseFlagView = SelectFlagView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        view.addSubview(chooseFlagView)
        chooseFlagView.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapFlagAction))
        chooseFlagView.addGestureRecognizer(tapGes)
    }
    
    func configureToolbar() {
        toolbar = BrowserToolbar(frame: frameForToolbarAtOrientation(), browser: self)
        view.addSubview(toolbar)
    }
    
    func setControlsHidden(_ hidden: Bool, animated: Bool) {
        
        UIView.animate(withDuration: 0.35, animations: { _ in
            let alpha: CGFloat = hidden ? 0.0 : 1.0
            self.toolbar.alpha = alpha
            self.toolbar.frame = hidden ? self.frameForToolbarHideAtOrientation() : self.frameForToolbarAtOrientation()
            
            self.closeButton.alpha = alpha
            self.closeButton.frame = hidden ? self.closeButton.hideFrame : self.closeButton.showFrame
            
            self.chooseFlagView.alpha = alpha
            self.chooseFlagView.frame = self.getSelectFlagFrame(isHidden: hidden)
        }, completion: nil)
        
        setNeedsStatusBarAppearanceUpdate()
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
        return CGRect(x: 0, y: view.bounds.size.height + height, width: view.bounds.size.width, height: height)
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
    
    @objc func closeButtonPressed(sender: UIButton) {
        determineAndClose()
    }
    
    @objc func tapFlagAction(sender: UITapGestureRecognizer) {
        chooseFlagView.isSelected = !chooseFlagView.isSelected
    }
     
    func presentAnimation() {
        view.isHidden = true
        view.alpha = 0.0
        
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options:UIViewAnimationOptions(),
            animations: {
                self.showButtons()
                self.backgroundView.alpha = 1.0
            },
            completion: { (Bool) -> Void in
                self.view.isHidden = false
                self.view.alpha = 1.0
                self.backgroundView.isHidden = true
        })
    }
    
    func dismissAnimation() {
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options:UIViewAnimationOptions(),
            animations: {
                self.backgroundView.alpha = 0.0
            },
            completion: { (Bool) -> () in
                self.dismissPhotoBrowser(animated: true)
        })
    }
    
    func getSelectFlagFrame(isHidden: Bool) -> CGRect {
        var frame = CGRect.zero
        if isHidden {
            frame.origin = CGPoint(x: PickerConstant.screenWidth - 44, y: -20)
            frame.size = CGSize(width: 30, height: 30)
        } else {
            frame.origin = CGPoint(x: PickerConstant.screenWidth - 44, y: 10)
            frame.size = CGSize(width: 30, height: 30)
        }
        return frame
    }
    
//    func cancelFetchOriginImage() {
//        if fetchOriginTimer != nil {
//            fetchOriginTimer.invalidate()
//            fetchOriginTimer = nil
//        }
//    }
//    
//    func startFetchOriginImage() {
//        cancelFetchOriginImage()
//        
//        fetchOriginTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(onFetchOriginImage(_:)), userInfo: nil, repeats: false)
//    }
    
//    @objc func onFetchOriginImage(_ timer: Timer) {
//        cancelFetchOriginImage()
//        
//        if let zoomPage = self.pagingScrollView.pageDisplayed(at: currentPageIndex) {
//            zoomPage.displayOriginImage()
//        }
//    }
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
//        startFetchOriginImage()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
        isEndAnimationByToolBar = true
    }
}

