//
//  PhotoPreviewViewController.swift
//  PhotoPicker
//
//  Created by Igor Belov on 12.07.2021.
//

import UIKit
import PhotosUI

final class PhotoPreviewViewController: UIViewController {
    // MARK: - Interface properties
    private lazy var imageView: UIImageView = {
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
        if configuration.allowsPhotoPreviewZoom {
            scrollView.delegate = self
            let doubleTap = UITapGestureRecognizer(
                target: self,
                action: #selector(handleScrollViewDoubleTap(_:)))
            doubleTap.numberOfTapsRequired = 2
            scrollView.addGestureRecognizer(doubleTap)
            scrollView.maximumZoomScale = 5.0
        }

        return scrollView
    }()

    // MARK: - Properties
    private let configuration: JustPhotoPickerConfiguration
    var asset: PHAsset!
    var image: UIImage!
    var imageInitialPortraitHeight: CGFloat!
    var imageInitialLandscapeWidth: CGFloat!

    private var imageSizeConstraints: [NSLayoutConstraint] = []
    private var imageInitialConstraints: [NSLayoutConstraint] = []

    // MARK: - Default methods
    init(configuration: JustPhotoPickerConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureToolbar()

        // The separation of the interface configuration into initial and final is required
        // because the image view cannot be centered inside scroll view before the main view appears.
        // Therefore, initially the image view is centered inside the main view to
        // correctly complete with transition.
        configureScrollView()
        applyInitialImageConfiguration()
        loadImage()

        // Add observer to update constraints right after device rotation occurs.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rotationOccurred),
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
        // When the view appears, apply final interface configuration to center the image view
        // inside the scroll view.
        applyFinalImageConfiguration()
        resetZoomScale()
    }

    // MARK: - Interface configuration
    private func configureToolbar() {
        navigationController?.isToolbarHidden = false
        toolbarItems = navigationController?.toolbarItems
    }

    private func configureScrollView() {
        view.addSubview(scrollView)
        let guide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }

    private func applyInitialImageConfiguration() {
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

    private func applyFinalImageConfiguration() {
        NSLayoutConstraint.deactivate(imageInitialConstraints)

        imageView.removeFromSuperview()
        scrollView.addSubview(imageView)

        // Check existence of an image in case the high-quality
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
    private func loadImage() {
        let manager = PhotoManager()
        manager.requestImage(for: asset, size: imageView.frame.size) { [weak self] image in
            guard let image = image else { return }
            self?.imageView.image = image
        }
    }

    // MARK: - Actions
    @objc private func rotationOccurred() {
        updateSizeConstraints()
    }

    @objc private func handleScrollViewDoubleTap(_ sender: UIGestureRecognizer) {
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

    func resetZoomScale() {
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
