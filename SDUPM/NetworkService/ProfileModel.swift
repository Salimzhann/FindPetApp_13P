//
//  ProfileModel.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 11.04.2025.
//

import Foundation


struct UserProfile: Decodable {
    let email: String
    let firstName: String
    let lastName: String
    let phone: String
    let id: String
    let isVerified: Bool
    let createdAt: String
    let petsCount: Int
    let lostPetsCount: Int
    let foundPetsCount: Int
    
    // Преобразование ключей из snake_case в camelCase
    enum CodingKeys: String, CodingKey {
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case phone
        case id
        case isVerified = "is_verified"
        case createdAt = "created_at"
        case petsCount = "pets_count"
        case lostPetsCount = "lost_pets_count"
        case foundPetsCount = "found_pets_count"
    }
}
