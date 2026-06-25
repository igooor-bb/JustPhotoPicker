//
//  PhotoManager.swift
//  PhotoPicker
//
//  Created by Igor Belov on 11.07.2021.
//

import UIKit
import PhotosUI

final class PhotoManager: NSObject {
    func requestAuthorization(completion: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(completion)
    }
    
    /// Fetch only Recents album.
    /// - Returns: Model of fetched Recents album.
    func fetchRecentsAlbum() -> AlbumModel? {
        let fetchOptions = PHFetchOptions()
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumUserLibrary,
            options: fetchOptions)
        
        let recents = smartAlbums.object(at: 0)
        var albumModel: AlbumModel?
        if let title = recents.localizedTitle {
            let assets = assets(in: recents)
            albumModel = AlbumModel(title: title, assets: assets)
        }
        
        return albumModel
    }
    
    /// Fetch all main photo albums.
    /// - Returns: List of fetched album models.
    func fetchAlbums() -> [AlbumModel] {
        let fetchOptions = PHFetchOptions()
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: fetchOptions)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumUserLibrary,
            options: fetchOptions)
        let allAlbums = [smartAlbums, userAlbums]
        var albums: [AlbumModel] = []
        for album in allAlbums {
            album.enumerateObjects { [unowned self] (collection, _, _) in
                if let title = collection.localizedTitle {
                    let assets = assets(in: collection)
                    albums.append(.init(title: title, assets: assets))
                }
            }
        }
        return albums
    }
    
    /// Returns assets from collection.
    /// - Parameter collection: Container collection.
    /// - Returns: Fetch result with assets.
    private func assets(in collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        let photosOptions = PHFetchOptions()
        photosOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]
        photosOptions.predicate = NSPredicate(
            format: "mediaType = %d",
            PHAssetMediaType.image.rawValue)
        
        return PHAsset.fetchAssets(in: collection, options: photosOptions)
    }
    
    /// Requests asset thumbnail of specified size.
    /// - Parameters:
    ///   - asset: Source asset.
    ///   - size: Size of the target image.
    ///   - completion: The closure that is executed when the request completes
    func requestThumbnail(for asset: PHAsset, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.resizeMode = .none
        options.deliveryMode = .highQualityFormat
        PHCachingImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: options) { (image, _) in
            completion(image)
        }
    }
    
    /// Requests high quality image of given asset.
    /// - Parameters:
    ///   - asset: Source asset.
    ///   - size: Size of the target image.
    ///   - completion: The closure that is executed when the request completes
    func requestImage(for asset: PHAsset, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: .init(),
            contentMode: .aspectFit,
            options: options) { (image, _) in
            completion(image)
        }
    }
    
    /// Returns high quality images from the list of assets.
    /// - Parameter assets: Source assets.
    /// - Returns: List of original images.
    func originalImages(for assets: [PHAsset]) -> [UIImage] {
        var originalImages: [UIImage] = []
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        
        for asset in assets {
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: .init(),
                contentMode: .aspectFill,
                options: options) { (image, _) in
                if let image = image {
                    originalImages.append(image)
                }
            }
        }
        return originalImages
    }
}
