//
//  PhotoPreviewViewController.swift
//  PhotoPicker
//
//  Created by Igor Belov on 12.07.2021.
//

import UIKit
import PhotosUI

internal final class PhotoPreviewViewController: UIViewController {
    // MARK: - Interface properties
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        if JustConfig.allowsPhotoPreviewZoom {
            scrollView.delegate = self
            let doubleTap = UITapGestureRecognizer(
                target: self,
                action: #selector(scrollViewDoubleTapped(_:)))
            doubleTap.numberOfTapsRequired = 2
            scrollView.addGestureRecognizer(doubleTap)
            scrollView.maximumZoomScale = 5.0
        }
        
        return scrollView
    }()
    
    // MARK: - Public properties
    public var asset: PHAsset!
    public var image: UIImage!
    public var imageInitialPortraitHeight: CGFloat!
    public var imageInitialLandscapeWidth: CGFloat!
    
    // MARK: - Properties
    private var imageSizeConstraints: [NSLayoutConstraint] = []
    private var imageInitialConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Default methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureToolbar()
        
        // The separation of the interface configuration into initial and final is required
        // because the imageview cannot be centered inside scrollview before the main view appears.
        // Therefore, initially the imageview is centered inside the main view to
        // correctly complete with transition.
        configureScrollview()
        setInitialImageConfiguration()
        fetchImage()
        
        // Add observer to update constraints right after device rotation occurs.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rotationOccured),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
    
    }
    
    deinit {
        // When deinitializing, rotation observer should be
        // removed as it is no longer needed.
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // When the view appears apply final interface configuration to center the imageview
        // inside the scrollview.
        finalImageConfiguration()
        setZoomScale()
    }
    
    // MARK: - Interface configuration
    private func configureToolbar() {
        navigationController?.isToolbarHidden = false
        toolbarItems = navigationController?.toolbarItems
    }
    
    private func configureScrollview() {
        view.addSubview(scrollView)
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    private func setInitialImageConfiguration() {
        view.addSubview(imageView)
        
        let guide = view.safeAreaLayoutGuide
        if UIWindow.isLandscape {
            imageInitialConstraints = [
                imageView.topAnchor.constraint(equalTo: guide.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                imageView.widthAnchor.constraint(equalToConstant: imageInitialLandscapeWidth)
            ]
        } else {
            imageInitialConstraints = [
                imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
                imageView.heightAnchor.constraint(equalToConstant: imageInitialPortraitHeight)
            ]
        }
        
        NSLayoutConstraint.activate(imageInitialConstraints)
    }
    
    private func finalImageConfiguration() {
        NSLayoutConstraint.deactivate(imageInitialConstraints)
        
        imageView.removeFromSuperview()
        scrollView.addSubview(imageView)
        
        // Check exitance of an image in case the high quality
        // version has already been fetched.
        if imageView.image == nil {
            imageView.image = image
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: imageView.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
        
        updateSizeConstraints()
    }
    
    private func updateSizeConstraints() {
        NSLayoutConstraint.deactivate(imageSizeConstraints)
        
        let viewWidth = view.frame.size.width
        let viewHeight = view.safeAreaLayoutGuide.layoutFrame.height
        let ratio = image.size.width / image.size.height
        
        var verticalPadding: CGFloat
        var horizontalPadding: CGFloat
        if UIWindow.isLandscape {
            let imageViewLandscapeWidth = viewHeight * ratio
            imageSizeConstraints = [
                imageView.widthAnchor.constraint(equalToConstant: imageViewLandscapeWidth),
                imageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor)
            ]
            verticalPadding = 0
            horizontalPadding = (viewWidth - imageViewLandscapeWidth) / 2
        } else {
            let imageViewPortraitHeight = viewWidth / ratio
            imageSizeConstraints = [
                imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
                imageView.heightAnchor.constraint(equalToConstant: imageViewPortraitHeight)
            ]
            verticalPadding = (viewHeight - imageViewPortraitHeight) / 2
            horizontalPadding = 0
        }
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding)
        NSLayoutConstraint.activate(imageSizeConstraints)
    }
    
    // MARK: - Data configuration
    private func fetchImage() {
        let manager = PhotoManager()
        manager.getImage(for: asset, size: imageView.frame.size) { [weak self] image in
            guard let image = image else { return }
            self?.imageView.image = image
        }
    }
    
    // MARK: - Actions
    @objc func rotationOccured() {
        updateSizeConstraints()
    }
    
    @objc func scrollViewDoubleTapped(_ sender: UIGestureRecognizer) {
        if scrollView.zoomScale >= scrollView.maximumZoomScale / 2.0 {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let center = sender.location(in: sender.view)
            let zoomRect = scrollView.zoomRectForScale(3 * scrollView.minimumZoomScale, center: center)
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
}

// MARK: - ZoomingViewController
extension PhotoPreviewViewController: ZoomingViewController {
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        return imageView
    }
}

// MARK: - UIScrollViewDelegate
extension PhotoPreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = 1.0
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalPadding = imageViewSize.height < scrollViewSize.height ?
            (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ?
            (scrollViewSize.width - imageViewSize.width) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding)
    }
}
