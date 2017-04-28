//
//  ViewController.swift
//  PicturePicker
//
//  Created by guang xu on 2017/4/25.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

    }

    @IBAction func enter(_ sender: Any) {

        PicturePicker.shared.startChoosePhotos(with: 5) { (images) in
            print("---------")
            print(images)
            print("---------")
        }
        
//        var images = [Photo]()
//        let photo1 = Photo(image: UIImage(named: "a.jpg")!)
//        images.append(photo1)
//        let photo2 = Photo(image: UIImage(named: "b.png")!)
//        images.append(photo2)
//        let photo3 = Photo(image: UIImage(named: "c.jpg")!)
//        images.append(photo3)
//        let photo4 = Photo(image: UIImage(named: "d.jpg")!)
//        images.append(photo4)
//        let photo5 = Photo(image: UIImage(named: "e.jpg")!)
//        images.append(photo5)
//        
//        let browser = BrowserViewController(photos: images)
//        browser.initializePage(at: 0)
//        self.present(browser, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

