import UIKit

struct MyPetModel {
    let id: Int
    let name: String
    let species: String
    let breed: String
    let age: String
    let color: String
    var images: [UIImage]
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
    
    func withImages(_ newImages: [UIImage]) -> MyPetModel {
        return MyPetModel(
            id: self.id,
            name: self.name,
            species: self.species,
            breed: self.breed,
            age: self.age,
            color: self.color,
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
