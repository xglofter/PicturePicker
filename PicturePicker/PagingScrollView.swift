//
//  PagingScrollView.swift
//
//  Created by Richard on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

class PagingScrollView: UIScrollView {

    fileprivate weak var browser: BrowserViewController?
    
    var numberOfPhotos: Int {
        return browser?.photos.count ?? 0
    }
    
    let sideMargin: CGFloat = 10
    let pageIndexTagOffset: Int = 1000
    
    fileprivate var visiblePages = [ZoomingScrollView]()
    fileprivate var recycledPages = [ZoomingScrollView]()
    
    convenience init(frame: CGRect, browser: BrowserViewController) {
        self.init(frame: frame)
        self.browser = browser
        
        isPagingEnabled = true
        
        updateFrame(with: bounds, pageIndex: browser.currentPageIndex)
    }

}

// MARK: - Internal Function

internal extension PagingScrollView {
    func updateFrame(with aBounds: CGRect, pageIndex: Int) {
        var frame = aBounds
        frame.origin.x -= sideMargin
        frame.size.width += (2 * sideMargin)
        
        self.frame = frame
        
        if visiblePages.count > 0 {
            for page in visiblePages {
                let pageIndex = page.tag - pageIndexTagOffset
                page.frame = frameForPage(at: pageIndex)
                page.setMaxMinZoomScalesForCurrentBounds()
            }
        }
        
        updateContentSize()
        updateContentOffset(at: pageIndex)
    }
    
    func updateContentSize() {
        contentSize = CGSize(width: bounds.size.width * CGFloat(numberOfPhotos),
                             height: bounds.size.height)
    }
    
    func updateContentOffset(at index: Int) {
        let pageWidth = bounds.size.width
        let newOffset = CGFloat(index) * pageWidth
        contentOffset = CGPoint(x: newOffset, y: 0)
    }

    func tilePages() {
        guard let browser = browser else { return }
        
        let firstIndex: Int = getFirstIndex()
        let lastIndex: Int = getLastIndex()
        
        visiblePages
            .filter({ $0.tag - pageIndexTagOffset < firstIndex ||  $0.tag - pageIndexTagOffset > lastIndex })
            .forEach { page in
                recycledPages.append(page)
                page.prepareForReuse()
                page.removeFromSuperview()
        }
        
        let visibleSet: Set<ZoomingScrollView> = Set(visiblePages)
        let visibleSetWithoutRecycled: Set<ZoomingScrollView> = visibleSet.subtracting(recycledPages) // 除去recycledPages的visiblePages
        visiblePages = Array(visibleSetWithoutRecycled)
        
        while recycledPages.count > 2 {
            recycledPages.removeFirst()
        }
        
        for index: Int in firstIndex...lastIndex {
            if visiblePages.filter({ $0.tag - pageIndexTagOffset == index }).count > 0 {
                continue
            }
            
            let page: ZoomingScrollView = ZoomingScrollView(frame: frame, browser: browser)
            page.frame = frameForPage(at: index)
            page.tag = index + pageIndexTagOffset
            page.photo = browser.photos[index]
            visiblePages.append(page)
            addSubview(page)
        }
        
        browser.prepareNearPhoto()
    }
    
    func reload() {
        visiblePages.forEach({$0.removeFromSuperview()})
        visiblePages.removeAll()
        recycledPages.removeAll()
    }
    
    func animate(_ frame: CGRect) {
        setContentOffset(CGPoint(x: frame.origin.x - sideMargin, y: 0), animated: true)
    }
    
    func pageDisplayed(at index: Int) -> ZoomingScrollView? {
        for page in visiblePages {
            if page.tag - pageIndexTagOffset == index {
                return page
            }
        }
        return nil
    }
}

// MARK: - Private Function

private extension PagingScrollView {
    func frameForPage(at index: Int) -> CGRect {
        var pageFrame = bounds
        pageFrame.size.width -= (2 * sideMargin)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + sideMargin
        return pageFrame
    }
    
    func getFirstIndex() -> Int {
        let firstIndex = Int(floor((bounds.minX + sideMargin * 2) / bounds.width))
        if firstIndex < 0 {
            return 0
        }
        if firstIndex > numberOfPhotos - 1 {
            return numberOfPhotos - 1
        }
        return firstIndex
    }
    
    func getLastIndex() -> Int {
        let lastIndex  = Int(floor((bounds.maxX - sideMargin * 2 - 1) / bounds.width))
        if lastIndex < 0 {
            return 0
        }
        if lastIndex > numberOfPhotos - 1 {
            return numberOfPhotos - 1
        }
        return lastIndex
    }
}
