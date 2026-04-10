#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'apple_maps_flutter'
  s.version          = '1.4.0'
  s.summary          = 'Apple Maps support for Flutter on iOS.'
  s.description      = <<-DESC
Flutter plugin that embeds Apple Maps with camera controls, annotations,
overlays, and snapshots on iOS.
                       DESC
  s.homepage         = 'https://github.com/ChristopherLinnett/apple_maps_flutter'
  s.license          = { :type => 'BSD-3-Clause', :file => '../LICENSE' }
  s.author           = { 'Christopher Linnett' => 'christopherlinnett@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/ChristopherLinnett/apple_maps_flutter.git', :tag => s.version.to_s }
  s.source_files     = 'apple_maps_flutter/Sources/apple_maps_flutter/**/*.swift'
  s.resource_bundles = {
    'apple_maps_flutter_privacy' => ['apple_maps_flutter/Sources/apple_maps_flutter/PrivacyInfo.xcprivacy']
  }
  s.dependency 'Flutter'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.9'
end
