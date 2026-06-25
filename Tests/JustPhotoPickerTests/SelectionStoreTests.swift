import XCTest
@testable import JustPhotoPicker

final class SelectionStoreTests: XCTestCase {
    func testSingleSelectionReplacesPreviousItem() {
        let store = SelectionStore<Int>(selectionLimit: 1, isSelectionRequired: false)

        let firstChange = store.toggle(1)
        let secondChange = store.toggle(2)

        XCTAssertEqual(firstChange.insertedItems, [1])
        XCTAssertEqual(firstChange.removedItems, [])
        XCTAssertEqual(secondChange.insertedItems, [2])
        XCTAssertEqual(secondChange.removedItems, [1])
        XCTAssertEqual(store.items, [2])
        XCTAssertFalse(store.contains(1))
        XCTAssertTrue(store.contains(2))
    }

    func testSingleSelectionTogglesSelectedItemOff() {
        let store = SelectionStore<Int>(selectionLimit: 1, isSelectionRequired: false)

        store.toggle(1)
        let change = store.toggle(1)

        XCTAssertEqual(change.insertedItems, [])
        XCTAssertEqual(change.removedItems, [1])
        XCTAssertEqual(store.items, [])
        XCTAssertFalse(store.canCompleteSelection)
    }

    func testMultipleSelectionKeepsSelectedItemsInOrder() {
        let store = SelectionStore<Int>(selectionLimit: 3, isSelectionRequired: false)

        store.toggle(1)
        store.toggle(2)
        store.toggle(3)

        XCTAssertEqual(store.items, [1, 2, 3])
        XCTAssertEqual(store.count, 3)
        XCTAssertTrue(store.canCompleteSelection)
    }

    func testSelectionLimitRejectsAdditionalItems() {
        var callbackCount = 0
        let store = SelectionStore<Int>(selectionLimit: 2, isSelectionRequired: false)
        store.onChange = { _ in
            callbackCount += 1
        }

        store.toggle(1)
        store.toggle(2)
        let change = store.toggle(3)

        XCTAssertFalse(change.hasChanges)
        XCTAssertEqual(change.insertedItems, [])
        XCTAssertEqual(change.removedItems, [])
        XCTAssertEqual(store.items, [1, 2])
        XCTAssertEqual(callbackCount, 2)
    }

    func testRequiredSelectionCanCompleteOnlyWhenLimitIsReached() {
        let store = SelectionStore<Int>(selectionLimit: 2, isSelectionRequired: true)

        XCTAssertFalse(store.canCompleteSelection)

        store.toggle(1)
        XCTAssertFalse(store.canCompleteSelection)

        store.toggle(2)
        XCTAssertTrue(store.canCompleteSelection)

        store.toggle(1)
        XCTAssertFalse(store.canCompleteSelection)
    }

    func testChangeCallbackReceivesTypedSnapshot() {
        var snapshots: [SelectionStoreSnapshot<Int>] = []
        let store = SelectionStore<Int>(selectionLimit: 2, isSelectionRequired: true)
        store.onChange = { snapshot in
            snapshots.append(snapshot)
        }

        store.toggle(1)
        store.toggle(2)

        XCTAssertEqual(snapshots.map(\.count), [1, 2])
        XCTAssertEqual(snapshots.map(\.selectedItems), [[1], [1, 2]])
        XCTAssertEqual(snapshots.map(\.canCompleteSelection), [false, true])
    }
}
