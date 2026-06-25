import Foundation

enum CellReuseIdentifier {
    static let album = "AlbumCell"
    static let photo = "PhotoCardCell"
}

enum LocalizationKey: String {
    case albums = "JustPhotoPicker.Albums"
    case cancel = "JustPhotoPicker.Cancel"
    case done = "JustPhotoPicker.Done"
    case emptyAlbum = "JustPhotoPicker.EmptyAlbumLabel"
    case fixedSelection = "JustPhotoPicker.FixedSelection"
    case permissionRequired = "JustPhotoPicker.PermissionRequired"
    case permissionRequiredDescription = "JustPhotoPicker.PermissionRequiredDescription"
    case selectedCount = "JustPhotoPicker.SelectedLabel"
    case selection = "JustPhotoPicker.Selection"
    case settings = "JustPhotoPicker.Settings"
}
