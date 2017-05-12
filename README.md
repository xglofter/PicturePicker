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

可以通过设置来改变式样

```
PickerConfig.pickerBackgroundColor = UIColor(/*...*/)
PickerConfig.pickerThemeColor = UIColor(/*...*/)
```

![展示效果](./screenshot.gif)


