import Peripheral

extension Favorites: PlaintextCodable {
    init(decoding content: String) throws {
        var favorites: Favorites = .init()
        for line in content.split(separator: "\n") {
            favorites.upsert(.init(string: line))
        }
        self = favorites
    }

    func encode() throws -> String {
        var result: String = ""
        for path in paths {
            result.append("\(path)\n")
        }
        return result
    }
}
