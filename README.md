# PicturePicker

使用方法：

## CocoaPods

```
platform :ios, '9.0'

target 'TestMyPodLib' do
  use_frameworks!

  pod 'PicturePicker', :git => 'https://github.com/xglofter/PicturePicker.git'
end
```

    $ pod install

## swift使用

参考Demo

```swift
@IBAction func onGoToPick(_ sender: Any) {
  PickerManager.shared.startChoosePhotos(with: 5) { (images) in
    thePickImages.removeAll()
    thePickImages.append(contentsOf: images)
    collectView.reloadData()
  }
}
```

![展示效果](./screenshot.gif)


