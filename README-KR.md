
![title](https://github.com/younatics/MediaBrowser/blob/master/Images/MediaBrowser_w.png?raw=true)

<p align="center">
  <a href="(https://github.com/younatics/MediaBrowser/blob/master/LICENSE" target="_blank"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat"></a>
  <img alt="Swift" src="https://img.shields.io/badge/Swift-3.1-orange.svg">
  <img alt="iOS 8.1+" src="https://img.shields.io/badge/iOS-8.1%2B-blue.svg">
  <a href="https://cocoapods.org/pods/MediaBrowser" target="_blank"><img alt="CocoaPods" src="http://img.shields.io/cocoapods/v/MediaBrowser.svg"></a>
  <a href="https://younatics.github.io/MediaBrowser" target="_blank"><img alt="CocoaDocs" src="https://github.com/younatics/MediaBrowser/blob/master/docs/badge.svg"></a>
  <a href="https://github.com/Carthage/Carthage" target="_blank"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
  <a href="https://github.com/Carthage/Carthage" target="_blank"><img alt="ReadMe-KR" src="https://img.shields.io/badge/한국어-리드미-red.svg"></a>
  
</p>


## Intoduction
🏞 **MediaBrowser**는 `UIImage`, `PHAsset` 또는 `URLs`을 사용하는 `라이브러리 Assets`, `웹 비디오/이미지` 또는 `로컬 파일`을 하나 이상의 사진이나 영상를 보여 줍니다. 
MediaBrowser는 웹에서 사진의 다운로드 및 캐싱을 처리합니다. 사진을 확대 축소할수 있으며 캡션을 선택 할수 있습니다. 사용자가 메인 이미지뷰나 그리드에서 하나 이상의 사진을 선택 할수 있는데에도 쓸수 있습니다.

또한 미디어브라우저는 
Also, MediaBrowser 캐싱에 대해서 [SDWebImage](https://github.com/rs/SDWebImage) 최신 버전을 사용하며, [MWPhotoBrowser](https://github.com/mwaterfall/MWPhotoBrowser)에 영향을 받았습니다.

| Single Photo | Multiple Photos And Video |
| ------------- | ------------------------ |
| ![SinglePhoto](https://github.com/younatics/MediaBrowser/blob/master/Images/SinglePhoto.gif?raw=true) | ![MultiplePhotosAndVideo](https://github.com/younatics/MediaBrowser/blob/master/Images/MultiplePhotosAndVideo.gif?raw=true) |
| Multiple Photo Grid | Multiple Photo Selection |
| ![MultiplePhotoGrid](https://github.com/younatics/MediaBrowser/blob/master/Images/MultiplePhotoGrid.gif?raw=true)  | ![PhotoSelection](https://github.com/younatics/MediaBrowser/blob/master/Images/PhotoSelection.gif?raw=true)  |
| Web Photos | Web Photos Grid |
| ![WebPhotos](https://github.com/younatics/MediaBrowser/blob/master/Images/WebPhotos.gif?raw=true)  | ![WebPhotoGrid](https://github.com/younatics/MediaBrowser/blob/master/Images/WebPhotoGrid.gif?raw=true)  |

## Requirements
`MediaBrowser` 는 스위프트 3으로 작성 되었으며 iOS 8.1이상이 요구 됩니다.

## 사용법
### 기본

Get `MediaBrowser` and set `MediaBrowserDelegate`
```Swift 
let browser = MediaBrowser(delegate: self)
self.navigationController?.pushViewController(browser, animated: true)

//MediaBrowserDelegate
func numberOfMedia(in mediaBrowser: MediaBrowser) -> Int {
  return mediaArray.count
}
    
func media(for mediaBrowser: MediaBrowser, at index: Int) -> Media {
  if index < mediaArray.count {
    return mediaArray[index]
  }
  return DemoData.localMediaPhoto(imageName: "MotionBookIcon", caption: "Photo at index is Wrong")
}
```

## 설치법
### Cocoapods
```ruby
pod 'MediaBrowser'
```
### Carthage
```
github "younatics/MediaBrowser"
```

## References
#### 애플리케이션에서 사용하신다면 PR해주시거나 알려주세요

## Updates
업데이트 상세 사항은 [CHANGELOG](https://github.com/younatics/MediaBrowser/blob/master/CHANGELOG.md)를 참고해주세요

## Author
[younatics 🇰🇷](http://younatics.github.io)

## License
**MediaBrowser**는 MIT라이센스를 따릅니다. [LICENSE](https://github.com/younatics/MediaBrowser/blob/master/LICENSE)를 참고 해주세요
