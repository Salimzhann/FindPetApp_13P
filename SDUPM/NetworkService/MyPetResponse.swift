import Foundation
import UIKit

struct MyPetResponse: Codable {
    let id: Int
    let name: String
    let species: String
    let breed: String?
    let age: Int?
    let color: String?
    let gender: String?
    let distinctive_features: String?
    let last_seen_location: String?
    let photos: [PetPhotoResponse]
    let status: String
    let created_at: String
    let updated_at: String
    let lost_date: String?
    let owner_id: Int
    
    var mainPhotoURL: URL? {
        if let primaryPhoto = photos.first(where: { $0.is_primary }) {
            return URL(string: primaryPhoto.photo_url)
        } else if let firstPhoto = photos.first {
            return URL(string: firstPhoto.photo_url)
        }
        return nil
    }
    
    
    func toMyPetModel() -> MyPetModel {
        // Convert PetPhotoResponse array to UIImage array
        // In a real app, you would download the images first
        let placeholderImage = UIImage(systemName: "photo") ?? UIImage()
        
        return MyPetModel(
            id: id,
            name: name,
            species: species,
            breed: breed ?? "",
            age: String(age ?? 0),
            color: color ?? "", //
            images: [placeholderImage], // This would be loaded from photo URLs
            status: status,
            description: distinctive_features ?? "",
            gender: gender ?? "",
            photoURLs: photos.map { $0.photo_url },
            lastSeenLocation: last_seen_location,
            lostDate: lost_date
        )
    }
}

struct PetPhotoResponse: Codable {
    let id: Int
    let pet_id: Int
    let photo_url: String
    let is_primary: Bool
    let created_at: String
}
