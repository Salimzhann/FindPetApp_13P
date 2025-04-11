//
//  LosePetsModel.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

import Foundation

struct LostPetResponse: Codable {
    let items: [LostPet]
    let total: Int?
}

struct LostPet: Codable {
    let id: Int
    let name: String
    let age: Int
    let gender: String
    let species: String
    let imageUrl: String?
}
