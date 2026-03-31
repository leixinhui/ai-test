import Foundation

struct ItemDTO: Codable, Identifiable {
    let id: Int
    let title: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case createdAt = "created_at"
    }
}

struct ItemCreateDTO: Codable {
    let title: String
}
