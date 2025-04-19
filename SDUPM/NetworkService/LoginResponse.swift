//
//  LoginResponse.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 19.04.2025.
//

// Путь: SDUPM/NetworkService/LoginResponse.swift

import Foundation

struct LoginResponse: Codable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}
