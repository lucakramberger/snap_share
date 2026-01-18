Pod::Spec.new do |s|
  s.name             = 'snap_share'
  s.version          = '1.0.0'
  s.summary          = 'Share content to Snapchat using Creative Kit.'
  s.description      = <<-DESC
A Flutter plugin to share photos, videos, and stickers to Snapchat
using Snapchat's Creative Kit (SCSDKCreativeKit).
                       DESC
  s.homepage         = 'https://github.com/lucakramberger/snap_share'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Luca Kramberger' => 'luca@kramberger.dev' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SnapSDK/SCSDKCreativeKit', '~> 2.0'
  s.platform         = :ios, '12.0'
  s.swift_version    = '5.0'
  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
