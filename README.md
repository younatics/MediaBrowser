
![title](Images/MediaBrowser_w.png)

<p align="center">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-3.1-orange.svg">
  <img alt="iOS 8.1+" src="https://img.shields.io/badge/iOS-8.1%2B-blue.svg">
  <a href="https://cocoapods.org/pods/MediaBrowser" target="_blank">
    <img alt="CocoaPods" src="http://img.shields.io/cocoapods/v/MediaBrowser.svg">
  </a>
  <a href="https://github.com/younatics/MediaBrowser" target="_blank">
    <img alt="Platform" src="https://img.shields.io/cocoapods/v/MediaBrowser.svg?style=flat">
  </a>
  <a href="http://cocoadocs.org/docsets/MediaBrowser" target="_blank">
    <img alt="CocoaDocs" src="https://img.shields.io/cocoapods/metrics/doc-percent/MediaBrowser.svg">
  </a>
  <a href="https://github.com/Carthage/Carthage" target="_blank">
    <img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat">
  </a>
    <a href="(https://github.com/younatics/MediaBrowser/blob/master/LICENSE" target="_blank">
    <img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat">
  </a>
</p>

## Intoduction
🏞 **MediaBrowser** can display one or more images or videos by providing either `UIImage` objects, `PHAsset` objects, or `URLs` to library assets, web images/videos or local files. MediaBrowser handles the downloading and caching of photos from the web seamlessly. Photos can be zoomed and panned, and optional (customisable) captions can be displayed. This can also be used to allow the user to select one or more photos using either the grid or main image view.

Also, MediaBrowser use latest [SDWebImage](https://github.com/rs/SDWebImage) version for caching, motivated by [MWPhotoBrowser](https://github.com/mwaterfall/MWPhotoBrowser)

| Single Photo | Multiple Photos And Video |
| ------------- | ------------------------ |
| ![SinglePhoto](Images/SinglePhoto.gif) | ![MultiplePhotosAndVideo](Images/MultiplePhotosAndVideo.gif) |
| Multiple Photo Grid | Multiple Photo Selection |
| ![MultiplePhotoGrid](Images/MultiplePhotoGrid.gif)  | ![PhotoSelection](Images/PhotoSelection.gif)  |
| Web Photos | Web Photos Grid |
| ![WebPhotos](Images/WebPhotos.gif)  | ![WebPhotoGrid](Images/WebPhotoGrid.gif)  |

## Requirements
`MediaBrowser` is written in Swift 3. Compatible with iOS 8.1+

## Usage
### Basic

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

## Installation
### Cocoapods
```ruby
pod 'MediaBrowser'
```
### Carthage
```
github "younatics/MediaBrowser"
```

## References
#### Please tell me or make pull request if you use this library in your application :) 

## Author
[younatics 🇰🇷](http://younatics.github.io)

## License
**MediaBrowser** is available under the MIT license. See the LICENSE file for more info.
