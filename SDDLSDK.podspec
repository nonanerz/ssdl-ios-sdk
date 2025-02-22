Pod::Spec.new do |spec|
  spec.name         = 'SDDLSDK'
  spec.version      = '1.0.22'
  spec.summary      = 'iOS SDK for SDDL deep links integration'
  spec.description  = 'SDDLSDK helps to integrate deep links from SDDL easily in iOS apps.'
  spec.homepage     = 'https://github.com/nonanerz/ssdl-ios-sdk'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Eduard' => 'bulavaeduard@gmail.com' }
  spec.platform     = :ios, '12.0'
  spec.ios.deployment_target = '12.0'
  spec.source       = { :git => 'https://github.com/nonanerz/ssdl-ios-sdk.git', :tag => spec.version }
  spec.source_files = 'SDDLSDK/**/*.{h,swift}'
  spec.module_map = 'SDDLSDK/module.modulemap'
  spec.exclude_files = ['SDDLSDK/SDDLSDK.docc', '.idea', '.git', '.DS_Store']
  spec.frameworks   = 'Foundation', 'UIKit'
  spec.requires_arc = true
  spec.static_framework = true
  spec.swift_versions = ['5.0']
  spec.pod_target_xcconfig = {
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    'DEFINES_MODULE' => 'YES'
  }
end
