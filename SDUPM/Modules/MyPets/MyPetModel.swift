//
//  MyPetModel.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 02.04.2025.
//

import Foundation


struct MyPetModel: Codable {
    let images: [String]
    let name: String
    let age: String
    let breed: String
    let gender: String
    let category: String
    let description: String
    let status: Bool
}
