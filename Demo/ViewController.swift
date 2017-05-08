//
//  ViewController.swift
//  Demo
//
//  Created by guang xu on 2017/5/4.
//  Copyright © 2017年 Richard. All rights reserved.
//

import UIKit
import PicturePicker

class ViewController: UIViewController {

    @IBOutlet weak var collectView: UICollectionView!
    
    fileprivate lazy var thePickImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        collectView.collectionViewLayout = layout
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onGoToPick(_ sender: Any) {
        
        PickerManager.shared.startChoosePhotos(with: 5) { (images) in
            print("---------")
            print(images)
            print(images.count)
            print("---------")
            self.thePickImages.removeAll()
            self.thePickImages.append(contentsOf: images)
            self.collectView.reloadData()
        }
    }
}


extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thePickImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ID_Cell", for: indexPath) as! DemoCollectionViewCell
        cell.imgView.image = thePickImages[indexPath.row]
        return cell
    }
}
