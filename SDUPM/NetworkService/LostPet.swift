//
//  LostPet.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 18.04.2025.
//

import Foundation

// Основная структура ответа
struct LostPetResponse: Codable {
    let items: [LostPet]
    let total: Int
    let page: Int
    let limit: Int
    let pages: Int
}

// Модель потерянного питомца
struct LostPet: Codable {
    let id: String
    let name: String
    let species: String
    let breed: String
    let photo_url: String?
    let status: String
    let lost_date: String?
    
    // Вычисляемое свойство для удобства
    var mainPhotoURL: URL? {
        guard let photoUrlString = photo_url else { return nil }
        return URL(string: photoUrlString)
    }
}
