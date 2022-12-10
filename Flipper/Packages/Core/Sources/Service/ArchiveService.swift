import Inject
import Analytics

import Combine
import Logging
import Foundation

@MainActor
public class ArchiveService: ObservableObject {
    private let logger = Logger(label: "archive-service")

    let appState: AppState
    @Inject var archive: Archive
    @Inject var analytics: Analytics
    private var disposeBag: DisposeBag = .init()

    @Published public private(set) var items: [ArchiveItem] = []
    @Published public private(set) var deleted: [ArchiveItem] = []

    public init(appState: AppState) {
        self.appState = appState
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        archive.items
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)

        archive.deletedItems
            .receive(on: DispatchQueue.main)
            .assign(to: \.deleted, on: self)
            .store(in: &disposeBag)
    }

    public func save(
        _ item: ArchiveItem,
        as newItem: ArchiveItem
    ) async throws {
        do {
            if item.name != newItem.name {
                try await archive.rename(item.id, to: newItem.name)
            }
            try await archive.upsert(newItem)
            recordEdit()
            appState.synchronize()
        } catch {
            logger.error("saving changes: \(error)")
            throw error
        }
    }

    public func delete(_ item: ArchiveItem) async throws {
        do {
            try await archive.delete(item.id)
            appState.synchronize()
        } catch {
            logger.error("deleting item: \(error)")
            throw error
        }
    }

    public func onIsFavoriteToggle(_ item: ArchiveItem) async throws {
        do {
            try await archive.onIsFavoriteToggle(item.path)
        } catch {
            logger.error("toggling favorite: \(error)")
            throw error
        }
    }

    public func importKey(_ item: ArchiveItem) async throws {
        do {
            try await archive.importKey(item)
            logger.info("imported: \(item.filename)")
            appState.imported.send(item)
            recordImport()
            appState.synchronize()
        } catch {
            logger.error("import: \(error)")
            throw error
        }
    }

    public func loadItem(url: URL) async throws -> ArchiveItem {
        let item = try await Sharing.importKey(from: url)
        return try await archive.copyIfExists(item)
    }

    public func restoreAll() {
        Task {
            do {
                try await archive.restoreAll()
                appState.synchronize()
            } catch {
                logger.error("restore all: \(error)")
            }
        }
    }

    public func deleteAll() {
        Task {
            do {
                try await archive.wipeAll()
            } catch {
                logger.error("delete all: \(error)")
            }
        }
    }

    public func backupKeys() {
        archive.backupKeys()
    }

    // MARK: Analytics

    func recordEdit() {
        analytics.appOpen(target: .keyEdit)
    }

    func recordImport() {
        analytics.appOpen(target: .keyImport)
    }
}
