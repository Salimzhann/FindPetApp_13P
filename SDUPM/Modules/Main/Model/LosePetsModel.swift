import Foundation
import CoreLocation

struct LostPetResponse: Codable {
    let items: [Pet]
    let total: Int?
}

struct LostPet {
    let id: Int
    let name: String
    let species: String
    let breed: String?
    let age: Int?
    let color: String
    let gender: String?
    let distinctive_features: String?
    let last_seen_location: String?
    let photos: [PetPhoto]
    let status: String
    let created_at: String
    let updated_at: String
    let lost_date: String?
    let owner_id: Int
    let imageUrl: String?
    let owner_phone: String?
    let coordX: String?  // Добавлено
    let coordY: String?  // Добавлено
    
    // Инициализатор из Pet
    init(from pet: Pet) {
        self.id = pet.id
        self.name = pet.name
        self.species = pet.species
        self.breed = pet.breed
        self.age = pet.age
        self.color = pet.color
        self.gender = pet.gender
        self.distinctive_features = pet.distinctive_features
        self.last_seen_location = pet.last_seen_location
        self.photos = pet.photos
        self.status = pet.status
        self.created_at = pet.created_at
        self.updated_at = pet.updated_at
        self.lost_date = pet.lost_date
        self.owner_id = pet.owner_id
        self.owner_phone = pet.owner_phone
        self.coordX = pet.coordX  // Добавлено
        self.coordY = pet.coordY  // Добавлено
        self.imageUrl = pet.photos.first(where: { $0.is_primary })?.photo_url ?? pet.photos.first?.photo_url
    }
    
    // Вычисляемое свойство для получения координат
    var coordinate: CLLocationCoordinate2D? {
        guard let coordXString = coordX,
              let coordYString = coordY,
              let latitude = Double(coordXString),
              let longitude = Double(coordYString) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
