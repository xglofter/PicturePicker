#
#  Be sure to run `pod spec lint PicturePicker.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "PicturePicker"
  s.version      = "0.0.1"
  s.summary      = "a custom picture picker."
  s.description  = <<-DESC
                     a picture picker on ios.
                   DESC
  s.homepage     = "https://github.com/xglofter/PicturePicker"
  s.screenshots  = "https://github.com/xglofter/PicturePicker/screenshot.gif"
  s.license      = "MIT"
  s.author             = { "Richard" => "269243666@qq.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/xglofter/PicturePicker.git" }
  s.source_files  = "PicturePicker/*.{h,swift}"
  s.module_name = "PicturePicker"
  s.requires_arc = true

end
