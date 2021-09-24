//
//  Bundle+Local.swift
//  JustPhotoPicker
//
//  Created by Igor Belov on 24.09.2021.
//

import Foundation

private class BundleHelper {}

extension Bundle {
    static var local: Bundle {
    #if SWIFT_PACKAGE
        return Bundle.module
    #else
        return Bundle(for: BundleHelper.self)
    #endif
    }
}
