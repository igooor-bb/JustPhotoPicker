//
//  JustPhotoPickerView.swift
//  JustPhotoPicker
//
//  Created by Igor Belov on 24.08.2022.
//

import SwiftUI

public struct JustPhotoPickerView: UIViewControllerRepresentable {
    
    private var configuration: JustPhotoPickerConfiguration?
    private var didFinishPicking: (([UIImage]) -> Void)?
    private var didCancelPicking: (() -> Void)?

    public init(configuration: JustPhotoPickerConfiguration? = nil) {
        self.configuration = configuration
    }

    public func makeUIViewController(context: Context) -> JustPhotoPicker {
        let config = self.configuration ?? JustPhotoPickerConfiguration()
        let photoPicker = JustPhotoPicker(configuration: config)

        photoPicker.didFinishPicking = { images, cancelled in
            guard !cancelled else {
                didCancelPicking?()
                return
            }

            didFinishPicking?(images)
        }

        return photoPicker
    }

    public func updateUIViewController(_ uiViewController: JustPhotoPicker, context: Context) {}
}

public extension JustPhotoPickerView {
    /// The modifier provides a callback to the event when a user selects images.
    func onFinish(_ action: @escaping ([UIImage]) -> Void) -> JustPhotoPickerView {
        var view = self
        view.didFinishPicking = action
        return view
    }

    /// The modifier provides a callback to the event when a user dismisses the picker.
    func onCancel(_ action: @escaping () -> Void) -> JustPhotoPickerView {
        var view = self
        view.didCancelPicking = action
        return view
    }
}
