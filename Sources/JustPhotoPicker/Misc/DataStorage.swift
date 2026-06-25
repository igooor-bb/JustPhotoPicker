//
//  DataStorage.swift
//  PhotoPicker
//
//  Created by Igor Belov on 12.07.2021.
//

import Foundation
import PhotosUI

/// Span for temporary storage for selected images.
class DataStorage {
    static let shared = DataStorage()
    private init() {}
    
    private var selectedAssets = Set<PHAsset>() {
        didSet {
            // Send a notification when the number of selected photos changes.
            // Used to display a counter of selected photos in toolbar.
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .selectionChanged, object: nil)
        }
    }
    
    var count: Int {
        return selectedAssets.count
    }
    
    func contains(_ asset: PHAsset) -> Bool {
        return selectedAssets.contains(asset)
    }
    
    func remove(_ asset: PHAsset) {
        selectedAssets.remove(asset)
    }
    
    func removeAll() {
        selectedAssets.removeAll()
    }
    
    var assets: [PHAsset] {
        return Array(selectedAssets)
    }
    
    func insert(_ asset: PHAsset) {
        selectedAssets.insert(asset)
    }
    
    func popFirstAsset() -> PHAsset? {
        return selectedAssets.popFirst()
    }
}
