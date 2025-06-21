import Foundation

struct LoginResponse: Codable {
    let accessToken: String
    let tokenType: String
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case userId = "user_id"
    }
}
