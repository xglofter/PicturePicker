//
//  zoomingScrollView.swift
//
//  Created by Richard on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit
import Photos

class ZoomingScrollView: UIScrollView {

    var photo: PhotoProtocol! {
        didSet {
            photoImageView.image = nil
            if photo != nil {
                displayImage()
            }
        }
    }
    
    fileprivate weak var photoBrowser: BrowserViewController!
    fileprivate var photoImageView: TapImageView!
    fileprivate var tapView: TapView!
    
    fileprivate var fetchOriginTimer: Timer!
    
    convenience init(frame: CGRect, browser: BrowserViewController) {
        self.init(frame: frame)
        photoBrowser = browser
        setupWidgets()
    }
    
    override func layoutSubviews() {
        
        tapView.frame = bounds
        
        super.layoutSubviews()
        
        let boundsSize = bounds.size
        var frameToCenter = photoImageView.frame
        
        // horizon
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2)
        } else {
            frameToCenter.origin.x = 0
        }
        // vertical
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2)
        } else {
            frameToCenter.origin.y = 0
        }
        
        // Center
        if !photoImageView.frame.equalTo(frameToCenter) {
            photoImageView.frame = frameToCenter
        }
    }
    
}

// MARK: - Internal Function

internal extension ZoomingScrollView {
    func setMaxMinZoomScalesForCurrentBounds() {
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        
        guard let photoImageView = photoImageView else {
            return
        }
        
        let boundsSize = bounds.size
        let imageSize = photoImageView.frame.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale: CGFloat = min(xScale, yScale)
        var maxScale: CGFloat = 1.0
        
        let scale = max(UIScreen.main.scale, 2.0)
        let deviceScreenWidth = UIScreen.main.bounds.width * scale // width in pixels. scale needs to remove if to use the old algorithm
        let deviceScreenHeight = UIScreen.main.bounds.height * scale // height in pixels. scale needs to remove if to use the old algorithm
        
        if photoImageView.frame.width < deviceScreenWidth {
            // I think that we should to get coefficient between device screen width and image width and assign it to maxScale. I made two mode that we will get the same result for different device orientations.
            if UIApplication.shared.statusBarOrientation.isPortrait {
                maxScale = deviceScreenHeight / photoImageView.frame.width
            } else {
                maxScale = deviceScreenWidth / photoImageView.frame.width
            }
        } else if photoImageView.frame.width > deviceScreenWidth {
            maxScale = 1.0
        } else {
            // here if photoImageView.frame.width == deviceScreenWidth
            maxScale = 2.5
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale
        zoomScale = minScale
        
        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        // maximum zoom scale to 0.5
        // After changing this value, we still never use more
        /*
         maxScale = maxScale / scale
         if maxScale < minScale {
         maxScale = minScale * 2
         }
         */
        
        // reset position
        photoImageView.frame = CGRect(x: 0, y: 0, width: photoImageView.frame.size.width, height: photoImageView.frame.size.height)
        setNeedsLayout()
    }
    
    func prepareForReuse() {
        photo = nil
        cancelFetchOriginImage()
    }
    
    func displayImage() {
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        contentSize = CGSize.zero
        
        var imageToSet: UIImage!
        if photo.originImage != nil {
            imageToSet = photo.originImage
        } else if photo.underlyingImage != nil {
            imageToSet = photo.underlyingImage
            startFetchOriginImage()
        } else {
            photo.fetchUnderlyingImage { [weak self] _ in
                if let thePhotoImage = self?.photo?.underlyingImage {
                    self?.setImage(image: thePhotoImage)
                    self?.startFetchOriginImage()
                }
            }
            return
        }
        setImage(image: imageToSet)
        
        let number = PickerManager.shared.getPhotoNumber(with: photo.asset.localIdentifier)
        photoBrowser?.setFlag(isSelected: (number != 0), with: number)
    }
    
    func displayOriginImage() {
        if let image = photo.originImage {
            setImage(image: image)
        } else {
            photo.fetchOriginImage(completion: { [weak self] _ in
                if let thePhotoImage = self?.photo?.originImage {
                    self?.setImage(image: thePhotoImage)
                }
            })
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ZoomingScrollView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
}

// MARK: - TapViewDelegate

extension ZoomingScrollView: TapViewDelegate {
    func handleTapViewSingleTap(from view: UIView, touch: UITouch) {
        guard let browser = photoBrowser else {
            return
        }
        guard PickerConfig.browserEnableZoomBlackArea == true else {
            return
        }
        
        browser.toggleControls()
    }
    
    func handleTapViewDoubleTap(from view: UIView, touch: UITouch) {
        if PickerConfig.browserEnableZoomBlackArea == true {
            let needPoint = getViewFramePercent(view, touch: touch)
            handleDoubleTap(touchPoint: needPoint)
        }
    }
}

// MARK: - TapImageViewDelegate

extension ZoomingScrollView: TapImageViewDelegate {
    func handleImageViewSingleTap(at touchPoint: CGPoint) {
        guard let browser = photoBrowser else {
            return
        }

        browser.toggleControls()
    }
    
    func handleImageViewDoubleTap(at touchPoint: CGPoint) {
        handleDoubleTap(touchPoint: touchPoint)
    }
}

// MARK: - Private Function

private extension ZoomingScrollView {
    func setupWidgets() {
        backgroundColor = .clear
        delegate = self
        showsHorizontalScrollIndicator = PickerConfig.browserShowHorizontalScrollIndicator
        showsVerticalScrollIndicator = PickerConfig.browserShowVerticalScrollIndicator
        decelerationRate = UIScrollViewDecelerationRateFast
        
        tapView = TapView(frame: bounds)
        tapView.backgroundColor = .clear
        tapView.delegate = self
        addSubview(tapView)
        
        photoImageView = TapImageView(frame: frame)
        photoImageView.backgroundColor = .clear
        photoImageView.delegate = self
        addSubview(photoImageView)
    }
    
    func handleDoubleTap(touchPoint: CGPoint) {
        if let photoBrowser = photoBrowser {
            NSObject.cancelPreviousPerformRequests(withTarget: photoBrowser)
        }
        
        if zoomScale > minimumZoomScale {
            // zoom out
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            // zoom in
            // I think that the result should be the same after double touch or pinch
            /* var newZoom: CGFloat = zoomScale * 3.13
             if newZoom >= maximumZoomScale {
             newZoom = maximumZoomScale
             }
             */
            let zoomRect = zoomRectForScrollViewWith(maximumZoomScale, touchPoint: touchPoint)
            zoom(to: zoomRect, animated: true)
        }
    }

    func getViewFramePercent(_ view: UIView, touch: UITouch) -> CGPoint {
        let oneWidthViewPercent = view.bounds.width / 100
        let viewTouchPoint = touch.location(in: view)
        let viewWidthTouch = viewTouchPoint.x
        let viewPercentTouch = viewWidthTouch / oneWidthViewPercent
        
        let photoWidth = photoImageView.bounds.width
        let onePhotoPercent = photoWidth / 100
        let needPoint = viewPercentTouch * onePhotoPercent
        
        var Y: CGFloat!
        
        if viewTouchPoint.y < view.bounds.height / 2 {
            Y = 0
        } else {
            Y = photoImageView.bounds.height
        }
        let allPoint = CGPoint(x: needPoint, y: Y)
        return allPoint
    }
    
    func zoomRectForScrollViewWith(_ scale: CGFloat, touchPoint: CGPoint) -> CGRect {
        let w = frame.size.width / scale
        let h = frame.size.height / scale
        let x = touchPoint.x - (h / max(UIScreen.main.scale, 2.0))
        let y = touchPoint.y - (w / max(UIScreen.main.scale, 2.0))
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    func setImage(image: UIImage) {
        photoImageView.image = image
        
        var photoFrame = CGRect.zero
        photoFrame.size = image.size
        photoImageView.frame = photoFrame
        
        contentSize = photoFrame.size
        
        setMaxMinZoomScalesForCurrentBounds()
        
        setNeedsLayout()
    }
    
    func cancelFetchOriginImage() {
        if fetchOriginTimer != nil {
            fetchOriginTimer.invalidate()
            fetchOriginTimer = nil
        }
    }
    
    func startFetchOriginImage() {
        cancelFetchOriginImage()
        
        fetchOriginTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(onFetchOriginImage(_:)), userInfo: nil, repeats: false)
    }
    
    @objc func onFetchOriginImage(_ timer: Timer) {
        cancelFetchOriginImage()
        
        displayOriginImage()
    }
}
