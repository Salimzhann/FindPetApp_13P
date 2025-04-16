//
//  MyPetModel.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 02.04.2025.
//

// File path: SDUPM/Modules/MyPets/MyPetModel.swift

// File path: SDUPM/Modules/MyPets/MyPetModel.swift

import UIKit

struct MyPetModel {
    let id: Int
    let name: String
    let species: String
    let breed: String
    let age: String
    var images: [UIImage]  // Using 'var' to allow modification
    let status: String
    let description: String
    let gender: String
    let photoURLs: [String]
    let lastSeenLocation: String?
    let lostDate: String?
    
    // Helper computed properties
    var statusFormatted: String {
        switch status {
        case "lost":
            return "Lost"
        case "home":
            return "At Home"
        case "found":
            return "Found"
        default:
            return status.capitalized
        }
    }
    
    var statusColor: UIColor {
        switch status {
        case "lost":
            return .systemRed
        case "home":
            return .systemGreen
        case "found":
            return .systemBlue
        default:
            return .systemGray
        }
    }
    
    // Add this method to create a new instance with updated images
    func withImages(_ newImages: [UIImage]) -> MyPetModel {
        return MyPetModel(
            id: self.id,
            name: self.name,
            species: self.species,
            breed: self.breed,
            age: self.age,
            images: newImages,
            status: self.status,
            description: self.description,
            gender: self.gender,
            photoURLs: self.photoURLs,
            lastSeenLocation: self.lastSeenLocation,
            lostDate: self.lostDate
        )
    }
}
