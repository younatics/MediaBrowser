#
# Be sure to run `pod lib lint MediaBrowser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MediaBrowser'
  s.version          = '2.3.0'
  s.summary          = 'A simple iOS photo and video browser with optional grid view, captions and selections written in Swift5.'

  s.description = <<-DESCRIPTION
MediaBrowser can display one or more images or videos by providing either UIImage objects, PHAsset objects, or URLs to library assets, web images/videos or local files. MediaBrowser handles the downloading and caching of photos from the web seamlessly. Photos can be zoomed and panned, and optional (customisable) captions can be displayed. This can also be used to allow the user to select one or more photos using either the grid or main image view. Also, MediaBrowser use latest SDWebImage version for caching, motivated by MWPhotoBrowser            
        DESCRIPTION
  s.screenshots = [
    'https://raw.githubusercontent.com/younatics/MediaBrowser/master/Images/cocoapodsImage1.png',
    'https://raw.githubusercontent.com/younatics/MediaBrowser/master/Images/cocoapodsImage2.png',
    'https://raw.githubusercontent.com/younatics/MediaBrowser/master/Images/cocoapodsImage3.png',
    'https://raw.githubusercontent.com/younatics/MediaBrowser/master/Images/cocoapodsImage4.png'
  ]
  s.homepage         = 'https://github.com/younatics/MediaBrowser'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Seungyoun Yi" => "younatics@gmail.com" }
  s.social_media_url = 'https://twitter.com/younatics'

  s.source           = { 
    :git => 'https://github.com/younatics/MediaBrowser.git', 
    :tag => s.version.to_s }
  s.source_files     = 'MediaBrowser/*.swift'
  s.resources        = "MediaBrowser/*.xcassets"

  s.ios.deployment_target = '8.1'

  s.frameworks = 'ImageIO', 'QuartzCore', 'AssetsLibrary', 'MediaPlayer'
  s.weak_frameworks = 'Photos'

  s.dependency 'SDWebImage'
  s.dependency 'UICircularProgressRing'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
  s.requires_arc = true
end
