//
//  SelectionStore.swift
//  PhotoPicker
//
//  Created by Igor Belov on 12.07.2021.
//

import Foundation

struct SelectionStoreChange<Item: Hashable> {
    let removedItems: [Item]
    let insertedItems: [Item]

    var changedItems: [Item] {
        return removedItems + insertedItems
    }

    var hasChanges: Bool {
        return !changedItems.isEmpty
    }
}

struct SelectionStoreSnapshot<Item: Hashable> {
    let selectedItems: [Item]
    let canCompleteSelection: Bool

    var count: Int {
        return selectedItems.count
    }
}

final class SelectionStore<Item: Hashable> {
    var onChange: ((SelectionStoreSnapshot<Item>) -> Void)?

    private let selectionLimit: Int
    private let isSelectionRequired: Bool
    private var selectedItems: [Item] = []
    private var selectedItemsSet = Set<Item>()

    init(selectionLimit: Int, isSelectionRequired: Bool) {
        precondition(selectionLimit > 0, "Selection limit must be positive")
        self.selectionLimit = selectionLimit
        self.isSelectionRequired = isSelectionRequired
    }

    convenience init(configuration: JustPhotoPickerConfiguration) {
        self.init(
            selectionLimit: configuration.selectionLimit,
            isSelectionRequired: configuration.isSelectionRequired)
    }

    var count: Int {
        return selectedItems.count
    }

    var items: [Item] {
        return selectedItems
    }

    var canCompleteSelection: Bool {
        if isSelectionRequired {
            return count == selectionLimit
        } else {
            return count > 0
        }
    }

    func contains(_ item: Item) -> Bool {
        return selectedItemsSet.contains(item)
    }

    @discardableResult
    func toggle(_ item: Item) -> SelectionStoreChange<Item> {
        if contains(item) {
            return remove(item)
        }

        if selectionLimit == 1 {
            let removedItems = selectedItems
            selectedItems.removeAll()
            selectedItemsSet.removeAll()
            insert(item)
            return notifyIfNeeded(removedItems: removedItems, insertedItems: [item])
        }

        guard count < selectionLimit else {
            return SelectionStoreChange(removedItems: [], insertedItems: [])
        }

        insert(item)
        return notifyIfNeeded(removedItems: [], insertedItems: [item])
    }

    @discardableResult
    func removeAll() -> SelectionStoreChange<Item> {
        let removedItems = selectedItems
        selectedItems.removeAll()
        selectedItemsSet.removeAll()
        return notifyIfNeeded(removedItems: removedItems, insertedItems: [])
    }

    private func remove(_ item: Item) -> SelectionStoreChange<Item> {
        selectedItemsSet.remove(item)
        selectedItems.removeAll { $0 == item }
        return notifyIfNeeded(removedItems: [item], insertedItems: [])
    }

    private func insert(_ item: Item) {
        selectedItems.append(item)
        selectedItemsSet.insert(item)
    }

    private func notifyIfNeeded(removedItems: [Item], insertedItems: [Item]) -> SelectionStoreChange<Item> {
        let change = SelectionStoreChange(removedItems: removedItems, insertedItems: insertedItems)
        if change.hasChanges {
            onChange?(snapshot)
        }
        return change
    }

    var snapshot: SelectionStoreSnapshot<Item> {
        return SelectionStoreSnapshot(
            selectedItems: selectedItems,
            canCompleteSelection: canCompleteSelection)
    }
}
