//
//  DataLoadOperation.swift
//  PhotoPicker
//
//  Created by Igor Belov on 12.07.2021.
//

import UIKit
import PhotosUI

class DataLoadOperation: Operation {
    // MARK: - Public properties
    var image: UIImage?
    var loadingCompleteHandler: ((UIImage?) -> ())?
    
    // MARK: - Properties
    private var _asset: PHAsset
    private var _size: CGSize
    
    override var isAsynchronous: Bool {
        get {
            return true
        }
    }
    
    // MARK: - Methods
    init(_ asset: PHAsset, size: CGSize) {
        _asset = asset
        _size = size
    }
    
    override func main() {
        if isCancelled { return }
        
        let manager = PhotoManager()
        manager.getThumbnail(for: _asset, size: _size) { image in
            DispatchQueue.main.async() { [weak self] in
                guard let self = self else { return }
                if self.isCancelled { return }
                self.image = image ?? UIImage()
                self.loadingCompleteHandler?(self.image)
            }
        }
    }
    
    // MARK: - Static methods
    public static func getImage(for asset: PHAsset, size: CGSize) -> DataLoadOperation? {
        return DataLoadOperation(asset, size: size)
    }
}
