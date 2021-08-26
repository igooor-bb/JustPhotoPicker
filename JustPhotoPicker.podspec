Pod::Spec.new do |spec|
  spec.name         = "JustPhotoPicker"
  spec.version      = "1.1.0"
  spec.summary      = "Simple and minimalistic photo picker for iOS"
  spec.description  = "Simple and minimalistic photo picker for iOS written in Swift"
  spec.homepage     = "https://github.com/igooor-bb/JustPhotoPicker"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = "Igor Belov"
  spec.social_media_url   = "https://twitter.com/igooor_bb"

  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/igooor-bb/JustPhotoPicker.git", :tag => "#{spec.version}" }
  spec.source_files = "Source/**/*.swift",
  spec.swift_version = '5.1'
end
