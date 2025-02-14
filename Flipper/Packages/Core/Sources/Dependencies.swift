import Macro
import Analytics
import Peripheral
import Catalog

import Logging
import Combine
import Foundation

// Temporary service locator while refactoring in progress

public class Dependencies: ObservableObject {
    private static let queue = DispatchQueue(label: "com.flipper.dependencies")

    private static var sharedInstance: Dependencies?

    public static var shared: Dependencies {
        return queue.sync {
            sharedInstance ?? {
                let instance = Dependencies()
                sharedInstance = instance
                return instance
            }()
        }
    }

    private init() {
        LoggingSystem.bootstrap { _ in
            FileLogHandler(storage: self.loggerStorage)
        }
        AnalyticsSystem.bootstrap(
            [CountlyAnalytics(), ClickhouseAnalytics()]
        )

        logger.info("app version: \(Bundle.fullVersion)")
        logger.info("log level: \(UserDefaultsStorage.shared.logLevel)")
    }

    // MARK: Domain Model

    // logger

    public lazy var loggerStorage: LoggerStorage = {
        PlainLoggerStorage()
    }()

    // device

    public lazy var pairedDevice: PairedDevice = {
        PairedFlipper(
            central: Peripheral.Dependencies.central,
            storage: PlainDeviceStorage()
        )
    }()

    // archive

    public lazy var mobileArchiveStorage: ArchiveStorage = {
        MobileArchiveStorage()
    }()

    public lazy var archive: Archive = {
        let mobileArchive = MobileArchive(
            storage: mobileArchiveStorage
        )
        let mobileFavorites = MobileFavorites()
        let syncedManifest = SyncedItemsStorage()

        return Archive(
            archiveSync: ArchiveSync(
                flipperArchive: FlipperArchive(
                    pairedDevice: pairedDevice
                ),
                mobileArchive: mobileArchive,
                syncedManifest: syncedManifest),
            favoritesSync: FavoritesSync(
                mobileFavorites: mobileFavorites,
                flipperFavorites: FlipperFavorites(
                    pairedDevice: pairedDevice
                ),
                syncedFavorites: SyncedFavorites()),
            mobileFavorites: mobileFavorites,
            mobileArchive: mobileArchive,
            mobileNotes: NotesArchiveStorage(),
            deletedArchive: DeletedArchive(
                storage: DeletedArchiveStorage()
            ),
            syncedManifest: syncedManifest)
    }()

    // MARK: Application Model

    @MainActor
    public lazy var router: Router = {
        .init()
    }()

    @MainActor
    public lazy var central: Central = {
        .init(central: Peripheral.Dependencies.central)
    }()

    @MainActor
    public lazy var device: Device = {
        .init(
            central: central,
            pairedDevice: pairedDevice)
    }()

    @MainActor
    public lazy var networkMonitor: NetworkMonitor = {
        .init()
    }()

    @MainActor
    public lazy var archiveModel: ArchiveModel = {
        .init(archive: archive, synchronization: synchronization)
    }()

    @MainActor
    public lazy var synchronization: Synchronization = {
        .init(pairedDevice: pairedDevice, archive: archive, device: device)
    }()

    @MainActor
    public lazy var updateModel: UpdateModel = {
        .init(
            device: device,
            pairedDevice: pairedDevice,
            manifestSource: RemoteTargetManifestSource(
                manifestSource: RemoteFirmwareManifestSource()))
    }()

    @MainActor
    public lazy var emulate: Emulate = {
        .init(pairedDevice: pairedDevice)
    }()

    @MainActor
    public lazy var sharing: SharingModel = {
        .init()
    }()

    @MainActor
    public lazy var applications: Applications = {
        var devURL = #URL("https://catalog.flipp.dev/api/v0")
        var prodURL = #URL("https://catalog.flipperzero.one/api/v0")

        return .init(
            catalog: WebCatalog(
                baseURL: UserDefaultsStorage.shared.isDevCatalog
                    ? devURL
                    : prodURL),
            pairedDevice: pairedDevice
        )
    }()

    @MainActor
    public lazy var widget: TodayWidget = {
        .init(
            widgetStorage: FilteredWidgetStorage(
                widgetStorage: JSONTodayWidgetStorage(),
                mobileStorage: mobileArchiveStorage),
            emulate: emulate,
            archive: archive,
            central: central,
            device: pairedDevice)
    }()
}
