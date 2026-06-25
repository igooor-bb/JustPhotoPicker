//
//  JustPhotoPickerDelegate.swift
//  PhotoPicker
//
//  Created by Igor Belov on 11.07.2021.
//

import UIKit

public protocol JustPhotoPickerDelegate: AnyObject {
    /// Tells the delegate that the user has selected photos
    /// and closed the picker with the done button.
    /// - Parameters:
    ///   - photoPicker: The photo picker object that is notifying you
    ///   - images: Selected photos.
    func didSelect(with photoPicker: JustPhotoPicker, images: [UIImage])
    
    /// Tells the delegate that the user has not selected any photos and closed the picker.
    /// - Parameter photoPicker: The photo picker object that is notifying you
    /// that there are no photos selected.
    func didNotSelect(with photoPicker: JustPhotoPicker)
}
