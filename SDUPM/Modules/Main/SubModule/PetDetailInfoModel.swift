//
//  PetDetailInfoModel.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 04.04.2025.
//

import Foundation

struct PetDetailInfoModel: Codable {
    let images: [String]
    let name: String
    let breed: String
    let age: String
    let gender: String
    let description: String
    let phone: String
    let gisLing: String
}
