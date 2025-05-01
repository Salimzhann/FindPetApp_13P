import Foundation

struct PetSearchResponse: Codable {
    let matches: [PetMatch]
}

struct PetMatch: Codable {
    let pet: Pet
    let similarity_score: Double
    
    var similarityPercentage: Int {
        return Int(similarity_score * 100)
    }
}

struct Pet: Codable {
    let id: Int
    let name: String
    let species: String
    let breed: String?  // Optional if it might be missing
    let age: Int?       // Optional if it might be missing
    let color: String
    let gender: String?  // Optional if it might be missing
    let distinctive_features: String?  // Optional if it might be missing
    let last_seen_location: String?
    let photos: [PetPhoto]
    let status: String
    let created_at: String
    let updated_at: String
    let lost_date: String?
    let owner_id: Int
    let owner_phone: String?

    var mainPhotoURL: URL? {
        if let primaryPhoto = photos.first(where: { $0.is_primary }) {
            return URL(string: primaryPhoto.photo_url)
        } else if let firstPhoto = photos.first {
            return URL(string: firstPhoto.photo_url)
        }
        return nil
    }
}

struct PetPhoto: Codable {
    let id: Int
    let pet_id: Int
    let photo_url: String
    let is_primary: Bool
    let created_at: String
}
