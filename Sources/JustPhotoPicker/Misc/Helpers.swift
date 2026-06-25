//
//  Helpers.swift
//  JustPhotoPicker
//
//  Created by Igor Belov on 24.09.2021.
//

import Foundation

func localizedString(_ key: LocalizationKey) -> String {
    return Bundle.local.localizedString(forKey: key.rawValue, value: "", table: "JustPhotoPickerLocalizable")
}
