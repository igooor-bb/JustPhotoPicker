//
//  JustPhotoPicker.swift
//  PhotoPicker
//
//  Created by Igor Belov on 11.07.2021.
//

import UIKit

public final class JustPhotoPicker: UINavigationController {
    // MARK: - Interface properties
    private lazy var descriptionLabel: UIBarButtonItem = {
        let barItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        barItem.isEnabled = false
        return barItem
    }()
    
    private lazy var doneButton: UIBarButtonItem = {
        let done = UIBarButtonItem(
            title: localizedString(LocalizationKey.done),
            style: .done,
            target: self,
            action: #selector(doneAction))
        done.tintColor = configuration.accentColor
        return done
    }()
    
    // MARK: - Public properties
    /// The object that acts as the delegate of the photo picker.
    public weak var photoPickerDelegate: JustPhotoPickerDelegate?
    public var didFinishPicking: (([UIImage], Bool) -> Void)?
    
    // MARK: - Properties
    private let configuration: JustPhotoPickerConfiguration
    private let transition = ZoomTransitioningDelegate()
    
    // MARK: - Methods
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = transition
        
        configureToolbar()
        configureNavigationBar()
        
        // Setup an observer to track changes in the number of selected photos.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(updateToolbar),
            name: .selectionChanged,
            object: nil)
        
        // Initialize the first scene to display.
        let albumsList = AlbumsViewController(configuration: configuration)
        albumsList.fetchRecents = true
        viewControllers = [albumsList]
    }
    
    public init(configuration: JustPhotoPickerConfiguration) {
        self.configuration = configuration
        DataStorage.shared.removeAll()
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init() {
        // Default configuration.
        self.init(configuration: JustPhotoPickerConfiguration())
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Interface configuration
    private func configureNavigationBar() {
        navigationBar.tintColor = configuration.accentColor
    }
    
    private func configureToolbar() {
        let cancelButton = UIBarButtonItem(
            title: localizedString(LocalizationKey.cancel),
            style: .plain,
            target: self,
            action: #selector(cancelAction))
        cancelButton.tintColor = configuration.accentColor
        let items: [UIBarButtonItem] = [
            cancelButton,
            .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            descriptionLabel,
            .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton
        ]
        toolbarItems = items
        updateToolbar()
    }
    
    // MARK: - Toolbar methods
    @objc func updateToolbar() {
        updateToolbarLabel()
        checkDoneButtonCondition()
    }
    
    private func updateToolbarLabel() {
        let count = DataStorage.shared.count
        
        let localizedString = localizedString(LocalizationKey.selectedCount)
        let text = String(format: localizedString, count)
        descriptionLabel.title = text
    }
    
    private func checkDoneButtonCondition() {
        // Enable the done button only if it is satisfies requirements
        // set by configuration.
        let isSelectionRequired = configuration.isSelectionRequired
        let selectionLimit = configuration.selectionLimit
        
        var isEnabled: Bool
        if isSelectionRequired {
            isEnabled = DataStorage.shared.count == selectionLimit
        } else {
            isEnabled = DataStorage.shared.count > 0
        }
        doneButton.isEnabled = isEnabled
    }
    
    // MARK: - Actions
    @objc private func cancelAction() {
        DataStorage.shared.removeAll()
        photoPickerDelegate?.didNotSelect(with: self)
        didFinishPicking?([], true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneAction() {
        guard DataStorage.shared.count > 0 else {
            cancelAction()
            return
        }
        
        DispatchQueue.main.async { [unowned self] in
            let assets = DataStorage.shared.assets
            DataStorage.shared.removeAll()
            
            let manager = PhotoManager()
            let images: [UIImage] = manager.originalImages(for: assets)
            
            self.photoPickerDelegate?.didSelect(with: self, images: images)
            self.didFinishPicking?(images, false)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
