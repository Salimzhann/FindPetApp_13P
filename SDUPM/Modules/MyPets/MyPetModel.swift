//
//  MyPetModel.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 02.04.2025.
//

import Foundation


struct MyPetModel: Codable {
    let id: String
    let name: String
    let species: String
    let breed: String
    let photoURL: String
    let status: String
    let lostDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case species
        case breed
        case photoURL = "photo_url"
        case status
        case lostDate = "lost_date"
    }
}
