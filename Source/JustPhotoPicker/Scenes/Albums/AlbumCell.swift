//
//  AlbumCell.swift
//  PhotoPicker
//
//  Created by Igor Belov on 11.07.2021.
//

import UIKit

class AlbumCell: UITableViewCell {
    // MARK: - Interface properties
    private lazy var albumImage: UIImageView = {
        let albumImage = UIImageView()
        albumImage.layer.borderWidth = 0.5
        albumImage.layer.borderColor = UIColor.white.cgColor
        albumImage.layer.masksToBounds = true
        albumImage.backgroundColor = .clear
        albumImage.cornerRadius = JustConfig.albumThumbnailCornerRadius
        albumImage.contentMode = .scaleAspectFill
        albumImage.translatesAutoresizingMaskIntoConstraints = false
        return albumImage
    }()
    
    private lazy var albumTitle: UILabel = {
        let albumTitle = UILabel()
        albumTitle.translatesAutoresizingMaskIntoConstraints = false
        return albumTitle
    }()
    
    private lazy var albumItemsCount: UILabel = {
        let albumItemsCount = UILabel()
        albumItemsCount.translatesAutoresizingMaskIntoConstraints = false
        albumItemsCount.textColor = .lightGray
        return albumItemsCount
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.addArrangedSubview(albumTitle)
        stackView.addArrangedSubview(albumItemsCount)
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var indicatorView: UIImageView = {
        let indicator = UIImageView()
        let chevron = UIImage(systemName: "chevron.forward")
        indicator.image = chevron
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.tintColor = .lightGray
        return indicator
    }()
        
    // MARK: - Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Interface configuration
    private func setup() {
        contentView.addSubview(albumImage)
        contentView.addSubview(stackView)
        contentView.addSubview(indicatorView)
        
        let constraints = [
            albumImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            albumImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            contentView.bottomAnchor.constraint(equalTo: albumImage.bottomAnchor, constant: 10),
            albumImage.widthAnchor.constraint(equalTo: albumImage.heightAnchor),
            
            stackView.leftAnchor.constraint(equalTo: albumImage.rightAnchor, constant: 15),
            stackView.centerYAnchor.constraint(equalTo: albumImage.centerYAnchor),
            
            indicatorView.widthAnchor.constraint(equalToConstant: 14),
            indicatorView.heightAnchor.constraint(equalToConstant: 24),
            indicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            indicatorView.leftAnchor.constraint(equalTo: stackView.rightAnchor),
            contentView.rightAnchor.constraint(equalTo: indicatorView.rightAnchor, constant: 15)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
        
    public func configureAlbum(with model: AlbumModel) {
        albumTitle.text = model.title
        albumItemsCount.text = String(model.count)
        albumImage.image = nil
    }
    
    public func setAlbumThumbnail(_ image: UIImage?) {
        if let image = image {
            albumImage.image = image
        } else {
            albumImage.image = .none
        }
    }
}
