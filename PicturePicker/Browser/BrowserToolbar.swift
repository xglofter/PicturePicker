//
//  BrowserToolbar.swift
//  PicturePicker
//
//  Created by guang xu on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

class BrowserToolbar: UIToolbar {

    var toolCounterLabel: UILabel! // TODO: 移植到navigation title上
    var toolCounterButton: UIBarButtonItem!
    var toolPreviousButton: UIBarButtonItem!
    var toolNextButton: UIBarButtonItem!
    var toolActionButton: UIBarButtonItem!
    
    fileprivate weak var browser: BrowserViewController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, browser: BrowserViewController) {
        self.init(frame: frame)
        self.browser = browser
        
        setupApperance()
        setupPreviousButton()
        setupNextButton()
        setupCounterLabel()
        setupToolbar()
    }
    
    func updateToolbar(_ currentPageIndex: Int) {
        guard let browser = browser else { return }
        
        if browser.numberOfPhotos > 1 {
            toolCounterLabel.text = "\(currentPageIndex + 1) / \(browser.numberOfPhotos)"
        } else {
            toolCounterLabel.text = nil
        }
        
        toolPreviousButton.isEnabled = (currentPageIndex > 0)
        toolNextButton.isEnabled = (currentPageIndex < browser.numberOfPhotos - 1)
    }
}

private extension BrowserToolbar {
    func setupApperance() {
        backgroundColor = PickerConfig.browserToolbarColor
        clipsToBounds = true
        isTranslucent = true
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        
        // toolbar
        if !PickerConfig.browserShowToolbar {
            isHidden = true
        }
    }
    
    func setupToolbar() {
        guard let browser = browser else { return }
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        if browser.numberOfPhotos > 1 {
            items.append(toolPreviousButton)
        }
        
        items.append(flexSpace)
        items.append(toolCounterButton)
        items.append(flexSpace)
        
        if browser.numberOfPhotos > 1 {
            items.append(toolNextButton)
        }
        items.append(flexSpace)
        
        setItems(items, animated: false)
    }
    
    func setupPreviousButton() {
        let previousBtn = BrowserPreviousButton(frame: frame)
        previousBtn.addTarget(browser, action: #selector(BrowserViewController.gotoPreviousPage), for: .touchUpInside)
        toolPreviousButton = UIBarButtonItem(customView: previousBtn)
    }
    
    func setupNextButton() {
        let nextBtn = BrowserNextButton(frame: frame)
        nextBtn.addTarget(browser, action: #selector(BrowserViewController.gotoNextPage), for: .touchUpInside)
        toolNextButton = UIBarButtonItem(customView: nextBtn)
    }
    
    func setupCounterLabel() {
        toolCounterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 95, height: 40))
        toolCounterLabel.textAlignment = .center
        toolCounterLabel.backgroundColor = .clear
        toolCounterLabel.shadowColor = .black
        toolCounterLabel.shadowOffset = CGSize(width: 0.0, height: 1.0)
        toolCounterLabel.font = UIFont.systemFont(ofSize: 17)
        toolCounterLabel.textColor = UIColor.white
        toolCounterButton = UIBarButtonItem(customView: toolCounterLabel)
    }
    
}


class BrowserToolbarButton: UIButton {
    let insets: UIEdgeInsets = UIEdgeInsets(top: 13.25, left: 17.25, bottom: 13.25, right: 17.25)
    
    func setup(_ imageName: String) {
        backgroundColor = .clear
        imageEdgeInsets = insets
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        contentMode = .center
        
        let image = UIImage(named: imageName) ?? UIImage()
        setImage(image, for: UIControlState())
    }
}

class BrowserPreviousButton: BrowserToolbarButton {
    let imageName = "btn_common_back_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        setup(imageName)
    }
}

class BrowserNextButton: BrowserToolbarButton {
    let imageName = "btn_common_forward_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        setup(imageName)
    }
}

// MARK: - Browser Button

class BrowserButton: UIButton {
    var showFrame: CGRect!
    var hideFrame: CGRect!
    var insets: UIEdgeInsets {
        if UI_USER_INTERFACE_IDIOM() == .phone {
            return UIEdgeInsets(top: 15.25, left: 15.25, bottom: 15.25, right: 15.25)
        } else {
            return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }
    }
    var size: CGSize = CGSize(width: 44, height: 44)
    var margin: CGFloat = 5
    var buttonTopOffset: CGFloat { return 5 }
    
    func setup(_ imageName: String) {
        backgroundColor = .clear
        imageEdgeInsets = insets
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        
        let image = UIImage(named: imageName) ?? UIImage()
        setImage(image, for: UIControlState())
    }
    
    func setFrameSize(_ size: CGSize) {
        let newRect = CGRect(x: margin, y: buttonTopOffset, width: size.width, height: size.height)
        frame = newRect
        showFrame = newRect
        hideFrame = CGRect(x: margin, y: -20, width: size.width, height: size.height)
    }
}

class BrowserCloseButton: BrowserButton {
    let imageName = "btn_common_close_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        showFrame = CGRect(x: margin, y: buttonTopOffset, width: size.width, height: size.height)
        hideFrame = CGRect(x: margin, y: -20, width: size.width, height: size.height)
    }
}

