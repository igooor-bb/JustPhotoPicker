# JustPhotoPicker

<p align="left">
    <img src="https://img.shields.io/badge/SwiftPM-supported-brightgreen" />
    <img src="https://img.shields.io/github/license/igooor-bb/JustPhotoPicker" />
</p>

JustPhotoPicker is a simple and minimalistic photo picker for iOS written in Swift.

Initially, the project was made for personal purposes, but it was decided to make it publicly available for use and contribution in improvement.

<img src="./Images/demo.png" alt="Demo"/>

Source of sample images in the gallery: [The Verge](https://www.theverge.com/pages/wallpapers)

## Contents

-   [JustPhotoPicker](#justphotopicker)
    -   [Contents](#contents)
    -   [Requirements](#requirements)
    -   [Installation](#installation)
        -   [Using Swift Package Manager](#using-swift-package-manager)
        -   [CocoaPods compatibility](#cocoapods-compatibility)
    -   [Info.plist](#infoplist)
    -   [Usage in UIKit](#usage-in-uikit)
        -   [Configuration](#configuration)
        -   [Processing the result](#processing-the-result)
            -   [Using the delegate](#using-the-delegate)
            -   [Using the closure](#using-the-closure)
        -   [Display](#display)
    -   [Usage in SwiftUI](#usage-in-swiftui)
    -   [Configuration properties](#configuration-properties)
    -   [Localization](#localization)
    -   [Contribution](#contribution)
    -   [License](#license)

## Requirements

-   iOS/iPadOS 13.0+
-   Xcode 12.0+

## Installation

### Using Swift Package Manager

Swift Package Manager is the supported public distribution channel for JustPhotoPicker.

You can use Swift Package Manager to install JustPhotoPicker using Xcode:

1.  Open your project in Xcode
2.  Open "File" -> "Add Package Dependencies..."
3.  Paste the repository URL: <https://github.com/igooor-bb/JustPhotoPicker>
4.  Click "Add Package"

### CocoaPods compatibility

New versions of JustPhotoPicker are not published to CocoaPods Trunk. The podspec is kept only for projects that still use CocoaPods as an internal project generator or dependency manager.

For local integration, point CocoaPods to a checkout of the repository:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'ApplicationName' do
    pod 'JustPhotoPicker', :path => '../JustPhotoPicker'
end
```

For git-based integration, point CocoaPods to a tag:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'ApplicationName' do
    pod 'JustPhotoPicker', :git => 'https://github.com/igooor-bb/JustPhotoPicker.git', :tag => '1.3.0'
end
```

Private specs repositories are also supported by the podspec, but CocoaPods Trunk is no longer part of the release process.

## Info.plist

To make your application have access to photos, add the following entity to the file `Info.plist`:

-   Privacy - Photo Library Usage Description

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Some description</string>
```

## Usage in UIKit

First of all, import the module `JustPhotoPicker` into a file with your view controller:

```swift
import JustPhotoPicker
```

### Configuration

You can change some visual and logical parameters using the `JustPhotoPickerConfiguration` structure. Set all the options you want and create a picker with configuration as a parameter:

```swift
var config = JustPhotoPickerConfiguration()
config.selectionLimit = 2
config.isSelectionRequired = true
// Configuration vibes...
let photoPicker = JustPhotoPicker(configuration: config)
```

### Processing the result

#### Using the delegate

To obtain the selected photos or the fact that the photos were not selected, the `JustPhotoPickerDelegate` protocol can be used. 

1.  Setup a delegate for your photo picker:

```swift
photoPicker.photoPickerDelegate = self
```

2.  Make your view controller conform the delegate protocol and implement both required methods:

```swift
extension ViewController: JustPhotoPickerDelegate {
  func didSelect(with photoPicker: JustPhotoPicker, images: [UIImage]) {
    print("Selected \(image.count) images")
  }

  func didNotSelect(with photoPicker: JustPhotoPicker) {
    print("Did not select any images")
  }
}
```

#### Using the closure

You also can use `didFinishPicking` closure of `JustPhotoPicker` class to obtain the selected photos:

```swift
let photoPicker = JustPhotoPicker(configuration: config)
photoPicker.didFinishPicking = { images, canceled in
  if canceled {
    print("Did not select any images")
    return
  }

  print("Selected \(images.count) images")
}
```

The closure takes two parameters. The first one is either a list of selected images or an empty list in case if a user did not select any. The second parameter is a boolean flag indicating whether a user canceled the selection.

### Display

When you are ready to start picking photos, display the picker in the standard way:

```swift
present(photoPicker, animated: true)
```

## Usage in SwiftUI

Recently we added SwiftUI support for JustPhotoPicker. All you need to do is to call `JustPhotoPickerView` in the same way in the body of your SwiftUI:

```swift
VStack {
  Button("Select photo") {
    showingPicker = true
  }
}
.sheet(isPresented: $showingPicker) {
  JustPhotoPickerView(configuration: pickerConfig)
    .onFinish { images in
      print("Selected \(images.count) images")
    }
    .onCancel {
      print("Did not select any images")
    }
}
```

Learn more [here](Examples/JustPhotoPickerSwiftUI/JustPhotoPickerSwiftUI/ContentView.swift)

## Configuration properties

The following are some of the possible settings for the picker, which you can also find in the `JustPhotoPickerConfiguration` structure:

```swift
config.selectionLimit = 2
config.isSelectionRequired = true
config.showsBottomDescriptionLabel = true
config.portraitModeCellsInRow = 3
config.landscapeModeCellsInRow = 6
config.backgroundColor = .white
config.accentColor = .systemPink
config.albumThumbnailCornerRaduis = 5
config.photoCardCornerRaduis = 0
config.startsOnScreen = .photos
config.hidesEmptyAlbumLabel = true
config.showsPhotoPreview = true
config.allowsPhotoPreviewZoom = false
// Configuration vibes...
```

## Localization

JustPhotoPicker is now translated into the following languages:

-   English (Base)
-   German
-   French
-   Russian
-   Italian
-   Spanish
-   Romanian
-   Czech
-   Polish
-   Ukrainian

If you want to add or correct localization, you are welcome to [contribute](#contribution).

## Contribution

To contribute, use the follow "fork-and-pull" git workflow:

1.  Fork the repository on github
2.  Clone the project to your own machine
3.  Commit changes to your own branch
4.  Push your work back up to your fork
5.  Submit a pull request so that I can review your changes

*NOTE: Be sure to merge the latest from "upstream" before making a pull request!*

## License

JustPhotoPicker is available under the MIT license. See the LICENSE file for more info.
