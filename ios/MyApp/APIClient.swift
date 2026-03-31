import Foundation

enum APIError: Error {
    case invalidBaseURL
    case badStatus(Int)
    case decoding(Error)
}

struct APIClient {
    private let session: URLSession
    private let config: AppAPIConfiguration

    init(session: URLSession = .shared, config: AppAPIConfiguration = .fromBundle()) {
        self.session = session
        self.config = config
    }

    func fetchItems() async throws -> [ItemDTO] {
        let url = try config.url(path: "/items")
        var request = URLRequest(url: url)
        config.applySecurityHeaders(to: &request)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.badStatus(-1)
        }
        guard (200 ... 299).contains(http.statusCode) else {
            throw APIError.badStatus(http.statusCode)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = formatter.date(from: str) { return d }
            formatter.formatOptions = [.withInternetDateTime]
            guard let d2 = formatter.date(from: str) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(str)")
            }
            return d2
        }
        do {
            return try decoder.decode([ItemDTO].self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    func createItem(title: String) async throws -> ItemDTO {
        let url = try config.url(path: "/items")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        config.applySecurityHeaders(to: &request)
        request.httpBody = try JSONEncoder().encode(ItemCreateDTO(title: title))
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.badStatus(-1)
        }
        guard (200 ... 299).contains(http.statusCode) else {
            throw APIError.badStatus(http.statusCode)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = formatter.date(from: str) { return d }
            formatter.formatOptions = [.withInternetDateTime]
            guard let d2 = formatter.date(from: str) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(str)")
            }
            return d2
        }
        do {
            return try decoder.decode(ItemDTO.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}

struct AppAPIConfiguration {
    var scheme: String
    var host: String
    var port: String
    var apiKey: String?

    static func fromBundle() -> AppAPIConfiguration {
        let bundle = Bundle.main
        let scheme = (bundle.object(forInfoDictionaryKey: "API_SCHEME") as? String) ?? "http"
        let host = (bundle.object(forInfoDictionaryKey: "API_HOST") as? String) ?? "127.0.0.1"
        let port = (bundle.object(forInfoDictionaryKey: "API_PORT") as? String) ?? "8000"
        let key = bundle.object(forInfoDictionaryKey: "API_KEY") as? String
        let trimmed = key?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return AppAPIConfiguration(
            scheme: scheme,
            host: host,
            port: port,
            apiKey: trimmed.isEmpty ? nil : trimmed
        )
    }

    func url(path: String) throws -> URL {
        var c = URLComponents()
        c.scheme = scheme
        c.host = host
        if let p = Int(port) {
            c.port = p
        }
        c.path = path
        guard let u = c.url else { throw APIError.invalidBaseURL }
        return u
    }

    func applySecurityHeaders(to request: inout URLRequest) {
        if let apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        }
    }
}
