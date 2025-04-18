import Foundation

struct UserProfile: Codable {
    let email: String
    let fullName: String
    let phone: String
    let id: Int
    let isActive: Bool
    let isVerified: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case fullName = "full_name"
        case phone
        case id
        case isActive = "is_active"
        case isVerified = "is_verified"
        case createdAt = "created_at"
    }
}
