import XCTest
@testable import JustPhotoPicker

final class JustPhotoPickerConfigurationTests: XCTestCase {
    func testDefaultConfigurationValues() {
        let configuration = JustPhotoPickerConfiguration()

        XCTAssertEqual(configuration.selectionLimit, 1)
        XCTAssertFalse(configuration.isSelectionRequired)
        XCTAssertTrue(configuration.showsBottomDescriptionLabel)
        XCTAssertEqual(configuration.portraitModeCellsInRow, 3)
        XCTAssertEqual(configuration.landscapeModeCellsInRow, 5)
        XCTAssertEqual(configuration.startsOnScene, .photos)
    }

    func testConfigurationCanBeCustomized() {
        var configuration = JustPhotoPickerConfiguration()

        configuration.selectionLimit = 3
        configuration.isSelectionRequired = true
        configuration.showsBottomDescriptionLabel = false
        configuration.portraitModeCellsInRow = 4
        configuration.landscapeModeCellsInRow = 6
        configuration.startsOnScene = .albums

        XCTAssertEqual(configuration.selectionLimit, 3)
        XCTAssertTrue(configuration.isSelectionRequired)
        XCTAssertFalse(configuration.showsBottomDescriptionLabel)
        XCTAssertEqual(configuration.portraitModeCellsInRow, 4)
        XCTAssertEqual(configuration.landscapeModeCellsInRow, 6)
        XCTAssertEqual(configuration.startsOnScene, .albums)
    }
}
