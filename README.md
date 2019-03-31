
![title](https://github.com/younatics/MediaBrowser/blob/master/Images/MediaBrowser_w.png?raw=true)

<p align="center">
  <a href="(https://github.com/younatics/MediaBrowser/blob/master/LICENSE" target="_blank"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat"></a>
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5.0-orange.svg">
  <img alt="iOS 8.1+" src="https://img.shields.io/badge/iOS-8.1%2B-blue.svg">
  <a href="https://travis-ci.org/younatics/MediaBrowser" target="_blank"><img alt="travis" src="https://travis-ci.org/younatics/MediaBrowser.svg?branch=master"></a>
  <a href="https://cocoapods.org/pods/MediaBrowser" target="_blank"><img alt="CocoaPods" src="http://img.shields.io/cocoapods/v/MediaBrowser.svg"></a>
  <a href="https://younatics.github.io/MediaBrowser" target="_blank"><img alt="CocoaDocs" src="https://github.com/younatics/MediaBrowser/blob/master/docs/badge.svg"></a>
  <a href="https://github.com/Carthage/Carthage" target="_blank"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
  <a href="https://github.com/younatics/MediaBrowser/blob/master/README-KR.md" target="_blank"><img alt="ReadMe-KR" src="https://img.shields.io/badge/한국어-리드미-red.svg"></a>
</p>

## Introduction
🏞 **MediaBrowser** can display one or more images or videos by providing either `UIImage` objects, `PHAsset` objects, or `URLs` to library assets, web images/videos or local files. MediaBrowser handles the downloading and caching of photos from the web seamlessly. Photos can be zoomed and panned, and optional (customisable) captions can be displayed. This can also be used to allow the user to select one or more photos using either the grid or main image view.

Also, MediaBrowser use latest [SDWebImage](https://github.com/rs/SDWebImage) version for caching, motivated by [MWPhotoBrowser](https://github.com/mwaterfall/MWPhotoBrowser)

| Single Photo | Multiple Photos And Video |
| :----------: | :-----------------------: |
| ![SinglePhoto](https://github.com/younatics/MediaBrowser/blob/master/Images/SinglePhoto.gif?raw=true) | ![MultiplePhotosAndVideo](https://github.com/younatics/MediaBrowser/blob/master/Images/MultiplePhotosAndVideo.gif?raw=true) |
| **Multiple Photo Grid** | **Multiple Photo Selection** |
| ![MultiplePhotoGrid](https://github.com/younatics/MediaBrowser/blob/master/Images/MultiplePhotoGrid.gif?raw=true)  | ![PhotoSelection](https://github.com/younatics/MediaBrowser/blob/master/Images/PhotoSelection.gif?raw=true)  |
| **Web Photos** | **Web Photos Grid** |
| ![WebPhotos](https://github.com/younatics/MediaBrowser/blob/master/Images/WebPhotos.gif?raw=true)  | ![WebPhotoGrid](https://github.com/younatics/MediaBrowser/blob/master/Images/WebPhotoGrid.gif?raw=true)  |

## Requirements
`MediaBrowser` is written in Swift 5.0 Compatible with iOS 8.0+

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

### Advanced
<a href="https://younatics.github.io/MediaBrowser" target="_blank"><img alt="CocoaDocs" src="https://github.com/younatics/MediaBrowser/blob/master/docs/badge.svg"></a> is the best place to start!

You can also see all usage in demo project.

| Property | Type |
| -------- | ---  |
| `navigationBarTranslucent` | `Bool` |
| `navigationBarTextColor` | `UIColor` |
| `navigationBarTintColor` | `UIColor` |
| `statusBarStyle` | `UIStatusBarStyle` |
| `toolbarTextColor` | `UIColor` |
| `toolbarBarTintColor` | `UIColor` |
| `toolbarBackgroundColor` | `UIColor` |
| `hasBelongedToViewController` | `Bool` |
| `isVCBasedStatusBarAppearance` | `Bool` |
| `statusBarShouldBeHidden` | `Bool` |
| `displayActionButton` | `Bool` |
| `leaveStatusBarAlone` | `Bool` |
| `performingLayout` | `Bool` |
| `rotating` | `Bool` |
| `viewIsActive` | `Bool` |
| `didSavePreviousStateOfNavBar` | `Bool` |
| `skipNextPagingScrollViewPositioning` | `Bool` |
| `viewHasAppearedInitially` | `Bool` |
| `currentGridContentOffset` | `CGPoint` |
| `zoomPhotosToFill` | `Bool` |
| `displayMediaNavigationArrows` | `Bool` |
| `displaySelectionButtons` | `Bool` |
| `alwaysShowControls` | `Bool` |
| `enableGrid` | `Bool` |
| `enableSwipeToDismiss` | `Bool` |
| `startOnGrid` | `Bool` |
| `autoPlayOnAppear` | `Bool` |
| `hideControlsOnStartup` | `Bool` |
| `delayToHideElements` | `TimeInterval` |
| `captionAlpha` | `CGFloat` |
| `toolbarAlpha` | `CGFloat` |
| `loadingIndicatorInnerRingColor` | `UIColor` |
| `loadingIndicatorOuterRingColor` | `UIColor` |
| `loadingIndicatorInnerRingWidth` | `CGFloat` |
| `loadingIndicatorOuterRingWidth` | `CGFloat` |
| `loadingIndicatorFont` | `UIFont` |
| `loadingIndicatorFontColor` | `UIColor` |
| `loadingIndicatorShouldShowValueText` | `Bool` |
| `mediaSelectedOnIcon` | `UIImage?` |
| `mediaSelectedOffIcon` | `UIImage?` |
| `mediaSelectedGridOnIcon` | `UIImage?` |
| `mediaSelectedGridOffIcon` | `UIImage?` |
| `preCachingEnabled` | `Bool` |
| `cachingImageCount` | `Int` |
| `placeholderImage` | `(image: UIImage, isAppliedForAll: Bool)?` |

| Method | Explanation |
| ------ | ----------- |
| `setCurrentIndex(at index: Int)` | Set current indexPath when start. Also, set first before `preCachingEnabled` |

| Delegate | Explanation |
| -------- | ----------- |
| `func numberOfMedia(in mediaBrowser: MediaBrowser) -> Int` | Required protocol to use MediaBrowser. return media count | 
| `func media(for mediaBrowser: MediaBrowser, at index: Int) -> Media` | Required protocol to use MediaBrowser. return media | 
| `func mediaBrowserDidFinishModalPresentation(mediaBrowser: MediaBrowser)` | Optional protocol to mediaBrowser Did Finish Modal Presentation | 
| `func thumbnail(for mediaBrowser: MediaBrowser, at index: Int) -> Media` | Optional protocol to show thumbnail. return media. Recommand small size | 
| `func captionView(for mediaBrowser: MediaBrowser, at index: Int) -> MediaCaptionView?` | Optional protocol to show captionView. return MediaCaptionView. | 
| `func didDisplayMedia(at index: Int, in mediaBrowser: MediaBrowser)` | Optional protocol when need callback | 
| `func actionButtonPressed(at photoIndex: Int, in mediaBrowser: MediaBrowser)` | Optional protocol when need callback about action button | 
| `func isMediaSelected(at index: Int, in mediaBrowser: MediaBrowser) -> Bool` | Optional protocol when need callback about isMediaSelected | 
| `func mediaDid(selected: Bool, at index: Int, in mediaBrowser: MediaBrowser)` | Optional protocol when need callback about media selection | 
| `func title(for mediaBrowser: MediaBrowser, at index: Int) -> String?` | Optional protocol for title | 

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

## Updates
See [CHANGELOG](https://github.com/younatics/MediaBrowser/blob/master/CHANGELOG.md) for details

## Author
[younatics](https://twitter.com/younatics)
<a href="http://twitter.com/younatics" target="_blank"><img alt="Twitter" src="https://img.shields.io/twitter/follow/younatics.svg?style=social&label=Follow"></a>

## License
**MediaBrowser** is available under the MIT license. See the LICENSE file for more info.
