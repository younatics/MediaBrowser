#
# Be sure to run `pod lib lint ExpandableCell.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Shader'
  s.version          = '1.0.0'
  s.summary          = 'Easiest way to make shade view with Swift 3'

  s.description      = <<-DESC
Easiest way to make shade view with Swift 3    
                    DESC

  s.homepage         = 'https://github.com/younatics/Shader'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Seungyoun Yi" => "younatics@gmail.com" }

  s.source           = { :git => 'https://github.com/younatics/Shader.git', :tag => s.version.to_s }
  s.source_files     = 'Shader/*.swift'

  s.ios.deployment_target = '8.0'

  s.frameworks = 'UIKit','QuartzCore'
  s.requires_arc = true
end
