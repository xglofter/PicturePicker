//
//  PicturePickerTests.swift
//  PicturePickerTests
//
//  Created by guang xu on 2017/5/3.
//  Copyright © 2017年 Richard. All rights reserved.
//

import XCTest
@testable import PicturePicker

class PicturePickerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        PickerManager.shared.startChoosePhotos(with: 5) { (images) in
            print("---------")
            print(images)
            print(images.count)
            print("---------")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
