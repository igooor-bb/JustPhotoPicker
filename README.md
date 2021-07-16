# JustPhotoPicker

JustPhotoPicker is a simple and minimalistic photo picker for iOS written in Swift.

Initially, the project was made for personal purposes, but it was decided to make it publicly available for use and contribution in improvement.

## Contents

- [JustPhotoPicker](#justphotopicker)
  * [Contents](#contents)
  * [Requirements](#requirements)
  * [Info.plist](#infoplist)
  * [Usage](#usage)
    + [Configuration](#configuration)
    + [Processing the result](#processing-the-result)
    + [Display](#display)
  * [Configuration properties](#configuration-properties)
  * [License](#license)

## Requirements

- iOS/iPadOS 13.0+
- Xcode 11.0+

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
configuration.selectionLimit = 2
configuration.isSelectionRequired = true
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
print("Did select")
}

func didNotSelect(with photoPicker: JustPhotoPicker) {
print("didNot")
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

## License

JustPhotoPicker is available under the MIT license. See the LICENSE file for more info.
