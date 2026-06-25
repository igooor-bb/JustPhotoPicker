//
//  JustPhotoPickerConfiguration.swift
//  PhotoPicker
//
//  Created by Igor Belov on 13.07.2021.
//

import UIKit

// swiftlint:disable:next identifier_name
internal var JustConfig: JustPhotoPickerConfiguration { return JustPhotoPickerConfiguration.shared }

public struct JustPhotoPickerConfiguration {
    public static var shared: JustPhotoPickerConfiguration = JustPhotoPickerConfiguration()
    public init() {}
    
    /// Corner radius of photo album thumbnails.
    /// Must be non-negative.
    public var albumThumbnailCornerRadius: CGFloat = 5 {
        willSet {
            assert(newValue >= 0, "Corner radius must be non-negative")
        }
        didSet {
            let value = albumThumbnailCornerRadius
            albumThumbnailCornerRadius = value == 0 ? 1 : value
        }
    }
    
    /// Corner radius of photo grid thumbnails.
    /// Must be non-negative.
    public var photoCardCornerRadius: CGFloat = 3 {
        willSet {
            assert(newValue >= 0, "Corner radius must be non-negative")
        }
        didSet {
            let value = photoCardCornerRadius
            photoCardCornerRadius = value == 0 ? 1 : value
        }
    }
    
    /// Limit on the number of selected photos.
    /// Must be positive.
    public var selectionLimit: Int = 1 {
        willSet {
            assert(newValue > 0, "Selection limit must be positive")
        }
    }
    
    /// Boolean value indicating whether it is mandatory to select all photos
    /// limited by the *selectionLimit* parameter. Otherwise, the *done* button will not be active.
    public var isSelectionRequired: Bool = false
    
    /// Background color of scenes.
    public var backgroundColor: UIColor = .systemBackground
    
    /// Tint color of main ineractive elements.
    public var accentColor: UIColor = .systemBlue
    
    /// Color of the description labels text.
    public var labelColor: UIColor = .systemGray2
    
    /// Accent color of checkmark.
    public var checkmarkForegroundColor: UIColor = .systemBlue
    
    /// Background color of checkmark.
    public var checkmarkBackgroundColor: UIColor = .white
    
    /// Tint of a semi-transparent photo highlight layer.
    public var overlayTintColor: UIColor = .white
    
    /// Boolean value responsible for showing bottom description label.
    /// at photos grid scene.
    public var showsBottomDescriptionLabel: Bool = true
    
    /// Number of photo cells in one row of grid in portrait device mode.
    public var portraitModeCellsInRow: Int = 3
    
    /// Number of photo cells in one row of grid in landscape device mode.
    public var landscapeModeCellsInRow: Int = 5
    
    /// The scene that opens first.
    public var startsOnScene: JustPhotoPickerScene = .photos
    
    /// Spacing between photo cells in landscape mode.
    /// Must be non-negative.
    public var landscapeModeGridInterimSpacing: CGFloat = 3 {
        willSet {
            assert(newValue >= 0, "Spacing must be non-negative")
        }
    }

    /// Spacing between photo cells in portrait mode.
    /// Must be non-negative.
    public var portraitModeGridInterimSpacing: CGFloat = 5 {
        willSet {
            assert(newValue >= 0, "Spacing must be non-negative")
        }
    }
    
    /// Boolean value responsible for showing empty album description label.
    public var showsEmptyAlbumLabel: Bool = true
    
    /// Boolean value responsible for showing photo preview on long press.
    public var showsPhotoPreview: Bool = true
    
    /// Boolean value responsible for zooming photo on preview.
    public var allowsPhotoPreviewZoom: Bool = true
}
