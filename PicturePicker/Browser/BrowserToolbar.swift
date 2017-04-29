//
//  BrowserToolbar.swift
//  PicturePicker
//
//  Created by Richard on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

class BrowserToolbar: UIToolbar {

    var toolCounterLabel: UILabel!
    var toolCounterButton: UIBarButtonItem!
    var toolSelectButton: UIBarButtonItem!
    
    var selectFlagView: SelectFlagView!
    
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
        setupCounterLabel()
        setupSelectLabel()
        setupToolbar()
    }
    
    func updateToolbar(_ currentPageIndex: Int) {
        guard let browser = browser else { return }
        
        if browser.numberOfPhotos > 1 {
            toolCounterLabel.text = "\(currentPageIndex + 1) / \(browser.numberOfPhotos)"
        } else {
            toolCounterLabel.text = nil
        }
    }
}

private extension BrowserToolbar {
    func setupApperance() {
        backgroundColor = PickerConfig.browserToolbarColor
        clipsToBounds = true
        isTranslucent = true
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        
        if !PickerConfig.browserShowToolbar {
            isHidden = true
        }
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
    
    func setupSelectLabel() {
        selectFlagView = SelectFlagView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        selectFlagView.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: browser, action: #selector(BrowserViewController.tapSelectFlagView))
        selectFlagView.addGestureRecognizer(tapGes)
        toolSelectButton = UIBarButtonItem(customView: selectFlagView)
    }
    
    func setupToolbar() {
        guard let _ = browser else { return }
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(toolCounterButton)
        items.append(flexSpace)
        items.append(toolSelectButton)
        
        setItems(items, animated: false)
    }
}
