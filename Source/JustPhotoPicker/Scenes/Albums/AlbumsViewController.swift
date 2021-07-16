//
//  AlbumsViewController.swift
//  PhotoPicker
//
//  Created by Igor Belov on 11.07.2021.
//

import UIKit
import PhotosUI

class AlbumsViewController: UIViewController {
    // MARK: - Public properties
    public var fetchRecents: Bool = false
    
    // MARK: - Interface properties
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.estimatedRowHeight = 110
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let width = tableView.frame.size.width
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        tableView.tableFooterView = footerView
        return tableView
    }()
    
    // MARK: - Properties
    private let manager = PhotoManager()
    private var albumsData: [AlbumModel] = []
    private let loadingQueue = OperationQueue()
    private var loadingOperations: [IndexPath: DataLoadOperation] = [:]
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Albums"
        
        // The scene with photo grid is displayed first,
        // so redirect there to correctly display the back button.
        if fetchRecents && JustConfig.startsOnScene == .photos {
            fetchRecents = false
            let grid = PhotoGridViewController()
            grid.fetchRecents = true
            navigationController?.pushViewController(grid, animated: false)
        }
        
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureToolbar()
        fetchAlbums()
    }
    
    private func fetchAlbums() {
        albumsData = manager.fetchListOfAlbums()
        tableView.reloadData()
    }
    
    // MARK: - Interface configuration
    private func configureToolbar() {
        navigationController?.isToolbarHidden = false
        toolbarItems = navigationController?.toolbarItems
    }
    
    private func configureTableView() {
        tableView.register(AlbumCell.self, forCellReuseIdentifier: "AlbumCell")
        view.addSubview(tableView)
        
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            view.rightAnchor.constraint(equalTo: tableView.rightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - UITableViewDataSource
extension AlbumsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albumsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
        
        let index = indexPath.row
        let album = albumsData[index]
        cell.configureAlbum(with: album)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? AlbumCell else { return }
        
        let updateCellClosure: (UIImage?) -> () = { [unowned self] image in
            cell.setAlbumThumbnail(image)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        
        // Check if the corresponding data loader exists.
        if let dataLoader = loadingOperations[indexPath] {
            if let image = dataLoader.image {
                // Configure cell if the data already has been loaded.
                cell.setAlbumThumbnail(image)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                // Otherwise, add the completion handler to update
                // the cell thumbnail once the data arrives.
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
            // Сreate a data loader for the current index path.
            if let model = albumsData[indexPath.item].assets.lastObject {
                let size = CGSize(width: 100, height: 100)
                if let dataLoader = DataLoadOperation.getImage(for: model, size: size) {
                    dataLoader.loadingCompleteHandler = updateCellClosure
                    loadingQueue.addOperation(dataLoader)
                    loadingOperations[indexPath] = dataLoader
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Cancel pending data load operations when the data is no longer required.
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension AlbumsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // Initiate asynchronous loading of the assets for the cells
        // at the specified index paths.
        for indexPath in indexPaths {
            if let _ = loadingOperations[indexPath] { return }
            
            if let model = albumsData[indexPath.item].assets.lastObject {
                let size = CGSize(width: 100, height: 100)
                if let dataLoader = DataLoadOperation.getImage(for: model, size: size) {
                    loadingQueue.addOperation(dataLoader)
                    loadingOperations[indexPath] = dataLoader
                }
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

// MARK: - UITableViewDelegate
extension AlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let photoGrid = PhotoGridViewController()
        photoGrid.albumModel = albumsData[indexPath.row]
        navigationController?.pushViewController(photoGrid, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}
