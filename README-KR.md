
![title](https://github.com/younatics/MediaBrowser/blob/master/Images/MediaBrowser_w.png?raw=true)

<p align="center">
  <a href="https://github.com/younatics/MediaBrowser" target="_blank"><img alt="Swift Package Manager" src="https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen.svg"></a>
  <a href="https://cocoapods.org/pods/MediaBrowser" target="_blank"><img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/MediaBrowser.svg"></a>
  <img alt="iOS 13.0+" src="https://img.shields.io/badge/iOS-13.0%2B-blue.svg">
  <img alt="Swift 6.0" src="https://img.shields.io/badge/Swift-6.0-orange.svg">
  <a href="https://github.com/younatics/MediaBrowser/blob/master/LICENSE" target="_blank"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat"></a>
  <a href="https://younatics.github.io/MediaBrowser" target="_blank"><img alt="CocoaDocs" src="https://github.com/younatics/MediaBrowser/blob/master/docs/badge.svg"></a>
  <a href="https://github.com/younatics/MediaBrowser/blob/master/README.md" target="_blank"><img alt="ReadMe-EN" src="https://img.shields.io/badge/English-README-red.svg"></a>
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
`MediaBrowser`는 Swift 6으로 작성되었으며 iOS 13.0 이상이 필요합니다. Swift Package Manager와 CocoaPods를 지원합니다.

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
  guard mediaArray.indices.contains(index) else { return Media() }
  return mediaArray[index]
}
```

## 설치법
### Swift Package Manager
Xcode에서 **File ▸ Add Package Dependencies…**를 선택하고 다음 저장소 URL을 입력하세요.
```
https://github.com/younatics/MediaBrowser.git
```
또는 `Package.swift`에 다음을 추가하세요.
```swift
dependencies: [
    .package(url: "https://github.com/younatics/MediaBrowser.git", from: "3.0.0")
]
```
### CocoaPods
```ruby
pod 'MediaBrowser', '~> 3.0.0'
```

## References
#### 애플리케이션에서 사용하신다면 PR해주시거나 알려주세요

## Updates
업데이트 상세 사항은 [CHANGELOG](https://github.com/younatics/MediaBrowser/blob/master/CHANGELOG.md)를 참고해주세요

## Author
[younatics 🇰🇷](http://younatics.github.io)

## License
**MediaBrowser**는 MIT라이센스를 따릅니다. [LICENSE](https://github.com/younatics/MediaBrowser/blob/master/LICENSE)를 참고 해주세요
