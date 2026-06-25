//
//  DataLoadOperation.swift
//  PhotoPicker
//
//  Created by Igor Belov on 12.07.2021.
//

import UIKit
import PhotosUI

class DataLoadOperation: Operation {
    // MARK: - Properties
    var image: UIImage?
    var loadingCompleteHandler: ((UIImage?) -> Void)?
    
    // MARK: - Properties
    private var asset: PHAsset
    private var size: CGSize
    
    override var isAsynchronous: Bool {
        return true
    }
    
    // MARK: - Methods
    init(_ asset: PHAsset, size: CGSize) {
        self.asset = asset
        self.size = size
    }
    
    override func main() {
        if isCancelled { return }
        
        let manager = PhotoManager()
        manager.requestThumbnail(for: asset, size: size) { image in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.isCancelled { return }
                self.image = image ?? UIImage()
                self.loadingCompleteHandler?(self.image)
            }
        }
    }
    
    // MARK: - Static methods
    static func makeImageLoadOperation(for asset: PHAsset, size: CGSize) -> DataLoadOperation {
        return DataLoadOperation(asset, size: size)
    }
}
