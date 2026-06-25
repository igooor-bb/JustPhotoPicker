//
//  PhotoCardCell.swift
//  PhotoPicker
//
//  Created by Igor Belov on 10.07.2021.
//

import UIKit
import PhotosUI

internal final class PhotoCardCell: UICollectionViewCell {
    // MARK: - Interface properties
    // UIImageView to display a thumbnail.
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // UIView which is shown if a cell is selected.
    private let overlay: UIView = {
        let overlay = UIView()
        let backgroundColor = JustConfig.overlayTintColor
        overlay.backgroundColor = backgroundColor.withAlphaComponent(0.45)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        return overlay
    }()
    
    // Underlay for the checkmark.
    private lazy var indicatorView: UIView = {
        let indicatorView = UIView()
        indicatorView.backgroundColor = JustConfig.checkmarkBackgroundColor
        indicatorView.cornerRadius = 16
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    
    // Checkmark indicating that the cell is selected.
    private lazy var checkmarkImageView: UIImageView = {
        let checkmarkImage = UIImage(systemName: "checkmark.circle.fill")
        let checkmarkImageView = UIImageView(image: checkmarkImage)
        checkmarkImageView.tintColor = JustConfig.checkmarkForegroundColor
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        checkmarkImageView.contentMode = .scaleToFill
        return checkmarkImageView
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        super.prepareForReuse()
    }
    
    private func setup() {
        configureContentView()
        configureImageView()
        configureSelectionOverlay()
        overlay.isHidden = true
    }
    
    // MARK: - Inerface configuration
    private func configureContentView() {
        contentView.cornerRadius = JustConfig.photoCardCornerRadius
    }
    
    private func configureImageView() {
        contentView.addSubview(imageView)
        
        let constraints = [
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            contentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: imageView.rightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func configureSelectionOverlay() {
        contentView.addSubview(overlay)
        indicatorView.addSubview(checkmarkImageView)
        overlay.addSubview(indicatorView)
        
        let constraints: [NSLayoutConstraint] = [
            overlay.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlay.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            contentView.bottomAnchor.constraint(equalTo: overlay.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: overlay.rightAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: 32),
            indicatorView.widthAnchor.constraint(equalToConstant: 32),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 28),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 28),
            checkmarkImageView.centerXAnchor.constraint(equalTo: indicatorView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Data configuration
    
    /// Set a thumbnail of the cell with a given image.
    /// - Parameter image: Thumbnail image
    public func setThumbnail(_ image: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            if let image = image {
                self?.imageView.image = image
            } else {
                self?.imageView.image = .none
            }
        }
        
    }
    
    /// Set selection status of a photo.
    /// - Parameter status: Boolean value indicating whether the photo is visually selected.
    public func setSelection(_ status: Bool) {
        overlay.isHidden = !status
    }
    
    /// Returns UIImageView of the cell to use in scene transition.
    /// - Returns: UIImageView of the cell.
    public func getImageView() -> UIImageView? {
        return imageView
    }
}
