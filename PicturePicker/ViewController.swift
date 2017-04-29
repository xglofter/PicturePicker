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
            print(images.count)
            print("---------")
            var index = 0
            for img in images {
                let imageView = UIImageView(image: img)
                imageView.frame.origin = CGPoint(x: 10 + index * 100, y: 10 + index * 100)
                self.view.addSubview(imageView)
                index += 1
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

