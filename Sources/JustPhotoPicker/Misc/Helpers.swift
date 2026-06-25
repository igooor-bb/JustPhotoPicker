//
//  Helpers.swift
//  JustPhotoPicker
//
//  Created by Igor Belov on 24.09.2021.
//

import Foundation

internal func localizedString(for key: String) -> String {
    return Bundle.local.localizedString(forKey: key, value: "", table: "JustPhotoPickerLocalizable")
}
