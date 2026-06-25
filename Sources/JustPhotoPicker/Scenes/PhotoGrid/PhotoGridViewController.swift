//
//  PhotoPickerViewController.swift
//  PhotoPicker
//
//  Created by Igor Belov on 10.07.2021.
//

import UIKit
import PhotosUI

internal final class PhotoGridViewController: UIViewController {
    // MARK: - Public properties
    
    /// Album model item to display in grid.
    public var albumModel: AlbumModel?
    
    /// Boolean value Indicates that the album *"Recents"* should be displayed.
    /// It is used when opening a picker.
    public var fetchRecents: Bool = false
    
    // MARK: - Properties
    private var selectedIndexPath: IndexPath?
    private var imagesData = PHFetchResult<PHAsset>()
    private var photoManager = PhotoManager()
    private lazy var loadingQueue = OperationQueue()
    private lazy var loadingOperations: [IndexPath: DataLoadOperation] = [:]
    
    // MARK: - Interface properties
    private var topSpacing: CGFloat = 5
    private var bottomSpacing: CGFloat = 5
    private var leftSpacing: CGFloat = 5
    private var rightSpacing: CGFloat = 5
    private var interSpacing: CGFloat {
        let portrait = JustConfig.portraitModeGridInterimSpacing
        let landsacape = JustConfig.landscapeModeGridInterimSpacing
        return UIWindow.isLandscape ? landsacape : portrait
    }
    
    private var cellWidth: CGFloat {
        let landscapeNumber = JustConfig.landscapeModeCellsInRow
        let portraitNumber = JustConfig.portraitModeCellsInRow
        let itemsInRow = CGFloat(UIWindow.isLandscape ? landscapeNumber : portraitNumber)

        let spacing: CGFloat = leftSpacing + rightSpacing + 2 * interSpacing
        let cellWidth = (collectionView.frame.width - spacing) / itemsInRow
        return cellWidth
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = interSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 10,
            left: leftSpacing,
            bottom: bottomSpacing,
            right: rightSpacing)
        
        let collectionView = UICollectionView(
            frame: self.view.frame,
            collectionViewLayout: layout)
        
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()

    // The description is used to tell the user how many images he needs or can choose.
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = JustConfig.labelColor
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        return label
    }()
        
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.shared().register(self)
        
        // Check if a photo album data has already been passed to the controller.
        if let model = albumModel {
            imagesData = model.assets
            title = model.title
            if imagesData.count == 0 {
                if JustConfig.showsEmptyAlbumLabel {
                    showEmptyAlbumLabel()
                }
            }
        }
        
        view.backgroundColor = JustConfig.backgroundColor
        configureToolbar()
        configureCollectionView()
        configureDescriptionLabel()

        requestAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func requestAuthorization() {
        // Check access to photo gallery.
        photoManager.requestAuthorization { [unowned self] status in
            switch status {
            case .authorized, .limited:
                fetchData()
            default:
                DispatchQueue.main.async {
                    showPermissionAlert()
                }
            }
        }
    }
    
    private func fetchData() {
        DispatchQueue.main.async { [unowned self] in
            if fetchRecents {
                albumModel = photoManager.fetchRecentsAlbum()
            }
            
            if let model = albumModel {
                imagesData = model.assets
                title = model.title
                if imagesData.count == 0 {
                    if JustConfig.showsEmptyAlbumLabel {
                        showEmptyAlbumLabel()
                    }
                    return
                }
            }
            
            collectionView.reloadData()
            
            // Scroll to bottom of collection view.
            let item = self.collectionView(self.collectionView, numberOfItemsInSection: 0) - 1
            let lastItemIndex = IndexPath(item: item, section: 0)
            self.collectionView.scrollToItem(at: lastItemIndex, at: .top, animated: false)
        }
    }
    
    private func showEmptyAlbumLabel() {
        // Show the message if there are no photos in the album.
        collectionView.isHidden = true
        
        let label = UILabel()
        label.text = localizedString(for: "JustPhotoPicker.EmptyAlbumLabel")
        label.textColor = JustConfig.labelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        let constraints = [
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func showPermissionAlert() {
        // If there is no access to photos,
        // show an alert with the ability to go to the settings.
        let title = localizedString(for: "JustPhotoPicker.PermissionRequired")
        let message = localizedString(for: "JustPhotoPicker.PermissionRequiredDescription")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsTitle = localizedString(for: "JustPhotoPicker.Settings")
        let settingsAction = UIAlertAction(title: settingsTitle, style: .default) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        }
        
        let cancelTitle = localizedString(for: "JustPhotoPicker.Cancel")
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    // MARK: - Interface configuration
    private func configureToolbar() {
        navigationController?.isToolbarHidden = false
        toolbarItems = navigationController?.toolbarItems
    }
    
    private func configureCollectionView() {
        collectionView.register(PhotoCardCell.self, forCellWithReuseIdentifier: "PhotoCardCell")
        view.addSubview(collectionView)
        
        let guide = view.safeAreaLayoutGuide
        let constraints: [NSLayoutConstraint] = [
            collectionView.topAnchor.constraint(equalTo: guide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: guide.leftAnchor),
            guide.rightAnchor.constraint(equalTo: collectionView.rightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        if JustConfig.showsPhotoPreview {
            let longPress = UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleLongPress(_:)))
            longPress.minimumPressDuration = 0.5
            longPress.delaysTouchesBegan = true
            longPress.delegate = self
            collectionView.addGestureRecognizer(longPress)
        }
    }
    
    public func configureDescriptionLabel() {
        view.addSubview(descriptionLabel)
        
        var labelHeight: CGFloat = 28
        let selectionLimit = JustConfig.selectionLimit
        let hideLabel = !JustConfig.showsBottomDescriptionLabel
        
        if selectionLimit == 1 || hideLabel {
            // Hide description label if it needs to select only one photo
            // or corresponding option is set to true.
            descriptionLabel.isHidden = true
            labelHeight = 0
        } else {
            // Otherwise, show description message according
            // to the need to select a certain number of photos.
            let isSelectionRequired = JustConfig.isSelectionRequired
            if isSelectionRequired {
                let localizedString = localizedString(for: "JustPhotoPicker.FixedSelection")
                descriptionLabel.text = String(format: localizedString, selectionLimit)
            } else {
                let localizedString = localizedString(for: "JustPhotoPicker.Selection")
                descriptionLabel.text = String(format: localizedString, selectionLimit)
            }
        }
        
        let guide = view.safeAreaLayoutGuide
        let constraints: [NSLayoutConstraint] = [
            descriptionLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            descriptionLabel.leftAnchor.constraint(equalTo: guide.leftAnchor),
            guide.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            guide.rightAnchor.constraint(equalTo: descriptionLabel.rightAnchor),
            descriptionLabel.heightAnchor.constraint(equalToConstant: labelHeight)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Navigation
    func presentImageDetailsViewController(with asset: PHAsset) {
        // Perform transition to a detailed view image.
        
        photoManager.getThumbnail(for: asset, size: .init()) { [unowned self] image in
            // Get a thumbnail for preview during upload
            // and adjusting the size of UIImageView for the transition.
            guard let image = image else { return }
            
            let details = PhotoPreviewViewController()
            details.image = image
            // The asset is additionally needed for the subsequent
            // download of a high quality image.
            details.asset = asset
            
            // Calculate initial image size relative to safe area.
            let viewWidth = view.frame.size.width
            let viewHeight = view.safeAreaLayoutGuide.layoutFrame.height
            let ratio = image.size.width / image.size.height
            
            details.imageInitialPortraitHeight = viewWidth / ratio
            details.imageInitialLandscapeWidth = viewHeight * ratio
            
            DispatchQueue.main.async {
                guard navigationController?.topViewController == self else { return }
                self.navigationController?.pushViewController(details, animated: true)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoGridViewController: UICollectionViewDataSource {
    // swiftlint:disable:next line_length
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoCardCell else { return }
        
        let updateCellClosure: (UIImage?) -> Void = { [unowned self] image in
            cell.setThumbnail(image)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        
        // Check if the corresponding data loader exists.
        if let dataLoader = loadingOperations[indexPath] {
            if let image = dataLoader.image {
                // Configure cell if the data already has been loaded.
                cell.setThumbnail(image)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                // Otherwise, add the completion handler to update
                // the cell thumbnail once the data arrives.
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
            // Сreate a data loader for the current index path.
            let model = imagesData[indexPath.item]
            let size = CGSize(width: cellWidth, height: cellWidth)
            if let dataLoader = DataLoadOperation.getImage(for: model, size: size) {
                dataLoader.loadingCompleteHandler = updateCellClosure
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }

    // swiftlint:disable:next line_length
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Cancel pending data load operations when the data is no longer required.
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imagesData.count
    }

    // swiftlint:disable:next line_length
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PhotoCardCell",
            for: indexPath) as? PhotoCardCell
        else {
            return UICollectionViewCell()
        }
        let index = indexPath.item
        let asset = imagesData[index]
        cell.setSelection(DataStorage.shared.contains(asset))
        return cell
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension PhotoGridViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            // Initiate asynchronous loading of the assets for the cells
            // at the specified index paths.
            if loadingOperations[indexPath] != nil { return }
            
            let model = imagesData[indexPath.item]
            let size = CGSize(width: cellWidth, height: cellWidth)
            if let dataLoader = DataLoadOperation.getImage(for: model, size: size) {
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        // Cancel pending data load operations when the data is no longer required.
        for indexPath in indexPaths {
            if let dataLoader = loadingOperations[indexPath] {
                dataLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoGridViewController: UICollectionViewDelegateFlowLayout {
    // swiftlint:disable:next line_length
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        let asset = imagesData[index]
        
        let selectionLimit = JustConfig.selectionLimit
        if selectionLimit == 1 {
            // If a user can select only one image.
            guard !DataStorage.shared.contains(asset) else {
                // Remove selection if the cell has already been selected.
                DataStorage.shared.remove(asset)
                collectionView.reloadItems(at: [indexPath])
                return
            }
            // Otherwise, undo the previous selection and select a new cell.
            if let oldAsset = DataStorage.shared.getFirstAdded() {
                let oldIndex = imagesData.index(of: oldAsset)
                let oldIndexPath = IndexPath(item: oldIndex, section: 0)
                DataStorage.shared.insert(asset)
                collectionView.reloadItems(at: [oldIndexPath, indexPath])
            } else {
                DataStorage.shared.insert(asset)
                collectionView.reloadItems(at: [indexPath])
            }
        } else {
            // If a user can select several images.
            if DataStorage.shared.contains(asset) {
                // Remove selection if the cell has already been selected.
                DataStorage.shared.remove(asset)
            } else {
                // Otherwise, select a new cell.
                guard DataStorage.shared.count < selectionLimit else { return }
                DataStorage.shared.insert(asset)
            }
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver
// Needed to track changes in shared assets with limited access to the gallery
extension PhotoGridViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [unowned self] in
            requestAuthorization()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PhotoGridViewController: UIGestureRecognizerDelegate {
    @objc func handleLongPress(_ gestureReconizer: UILongPressGestureRecognizer) {
        // Handle long press gesture to perform transition
        // to scene with detailed image view.
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let position = gestureReconizer.location(in: self.collectionView)
            let indexPath = self.collectionView.indexPathForItem(at: position)
            if let indexPath = indexPath {
                // It is important to save the selected indexPath to get the photo
                // from which the transition will begin.
                selectedIndexPath = indexPath
                presentImageDetailsViewController(with: imagesData[indexPath.item])
            }
        }
    }
}

// MARK: - ZoomingViewController
extension PhotoGridViewController: ZoomingViewController {
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        if let indexPath = selectedIndexPath,
           let cell = collectionView.cellForItem(at: indexPath) as? PhotoCardCell {
            return cell.getImageView()
        } else {
            return nil
        }
    }
}
