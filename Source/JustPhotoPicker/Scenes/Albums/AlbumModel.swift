//
//  AlbumModel.swift
//  PhotoPicker
//
//  Created by Igor Belov on 11.07.2021.
//

import Foundation
import PhotosUI

struct AlbumModel {
    let title: String
    let count: Int
    let assets: PHFetchResult<PHAsset>
    
    internal init(title: String, assets: PHFetchResult<PHAsset>) {
        self.title = title
        self.count = assets.count
        self.assets = assets
    }
}
