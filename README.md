# JustPhotoPicker

<p align="left">
    <img src="https://img.shields.io/cocoapods/p/JustPhotoPicker" />
    <img src="https://img.shields.io/github/license/igooor-bb/JustPhotoPicker" />
    <img src="https://img.shields.io/cocoapods/v/JustPhotoPicker" />
</p>

JustPhotoPicker is a simple and minimalistic photo picker for iOS written in Swift.

Initially, the project was made for personal purposes, but it was decided to make it publicly available for use and contribution in improvement.

<img src="./Images/demo.gif" alt="Demo" style="zoom:67%;" />

## Contents

- [JustPhotoPicker](#justphotopicker)
  * [Contents](#contents)
  * [Requirements](#requirements)
  * [Installation](#installation)
    + [Using CocoaPods](#using-cocoapods)
    + [Using Swift Package Manager](#using-swift-package-manager)
  * [Info.plist](#infoplist)
  * [Usage](#usage)
    + [Configuration](#configuration)
    + [Processing the result](#processing-the-result)
    + [Display](#display)
  * [Configuration properties](#configuration-properties)
  * [Contribution](#contribution)
  * [License](#license)

## Requirements

- iOS/iPadOS 13.0+
- Xcode 11.0+

## Installation

### Using CocoaPods

You can use [CocoaPods](http://cocoapods.org/) to install `JustPhotoPicker` by adding folowing lines to your `Podfile`:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'ApplicationName' do
    pod 'JustPhotoPicker'
end
```

Then just write the command in the terminal to install:

```bash
$ pod install
```

### Using Swift Package Manager

You can use Swift Package Manager to install JustPhotoPicker using Xcode:

1. Open your project in Xcode
2. Open "File" -> "Swift Packages" -> "Add Package Dependency..."
3. Paste the repository URL: https://github.com/igooor-bb/JustPhotoPicker
4. Click "Next" a couple of times and finish adding


## Info.plist

To make your application have access to photos, add the following entity to the file `Info.plist`:

- Privacy - Photo Library Usage Description

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Some description</string>
```

## Usage

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

To obtain the selected photos or the fact that the photos were not selected, the `JustPhotoPickerDelegate` protocol is used. 

1. Setup a delegate for your photo picker:

```swift
photoPicker.photoPickerDelegate = self
```

2. Make your view controller conform the delegate protocol and implement both required methods:

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

### Display

When you are ready to start picking photos, display the picker in the standard way:

```swift
present(photoPicker, animated: true)
```

## Configuration properties

The following are some of the possible settings for the picker, which you can also find in the `JustPhotoPickerConfiguration`structure:

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

## Contribution
To contribute, use the follow "fork-and-pull" git workflow:
1. Fork the repository on github
2. Clone the project to your own machine
3. Commit changes to your own branch
4. Push your work back up to your fork
5. Submit a pull request so that I can review your changes

*NOTE: Be sure to merge the latest from "upstream" before making a pull request!*

## License

JustPhotoPicker is available under the MIT license. See the LICENSE file for more info.
