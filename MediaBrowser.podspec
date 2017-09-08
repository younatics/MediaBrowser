#
# Be sure to run `pod lib lint MediaBrowser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MediaBrowser'
  s.version          = '0.1.0'
  s.summary          = 'MediaBrowser!'

  s.description      = <<-DESC
Awesome Media Browser    
                    DESC

  s.homepage         = 'https://github.com/younatics/MediaBrowser'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Seungyoun Yi" => "younatics@gmail.com" }

  s.source           = { 
    :git => 'https://github.com/younatics/MediaBrowser.git', 
    :tag => s.version.to_s }
  s.source_files     = 'MediaBrowser/*.swift'
  s.resources        = "MediaBrowser/*.xcassets"

  s.ios.deployment_target = '8.1'

  s.frameworks = 'ImageIO', 'QuartzCore', 'AssetsLibrary', 'MediaPlayer'
  s.weak_frameworks = 'Photos'


  s.dependency 'MBProgressHUD', '~> 0.9'
  s.dependency 'DACircularProgress', '~> 2.3'
  s.dependency 'MapleBacon'
  s.dependency 'SDWebImage'

  s.requires_arc = true
end
