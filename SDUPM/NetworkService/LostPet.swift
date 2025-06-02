import Foundation

// Основная структура ответа
struct APILostPetResponse: Codable {
    let items: [APILostPet]
    let total: Int
    let page: Int
    let limit: Int
    let pages: Int
}

// Модель потерянного питомца (API)
struct APILostPet: Codable {
    let id: String
    let name: String
    let species: String
    let breed: String?
    let photo_url: String?
    let status: String
    let lost_date: String?
    
    var mainPhotoURL: URL? {
        guard let photoUrlString = photo_url else { return nil }
        return URL(string: photoUrlString)
    }
    
    // Конвертация APILostPet в Pet
    func toPet() -> Pet {
        var photos: [PetPhoto] = []
        if let photoUrl = photo_url {
            photos = [PetPhoto(
                id: 0,
                pet_id: Int(id) ?? 0,
                photo_url: photoUrl,
                is_primary: true,
                created_at: Date().ISO8601Format()
            )]
        }
        
        return Pet(
            id: Int(id) ?? 0,
            name: name,
            species: species,
            breed: breed,
            age: nil,
            color: "",
            gender: nil,
            distinctive_features: nil,
            last_seen_location: nil,
            photos: photos,
            status: status,
            created_at: Date().ISO8601Format(),
            updated_at: Date().ISO8601Format(),
            lost_date: lost_date,
            owner_id: 0,
            owner_phone: nil,
            coordX: nil,
            coordY: nil
        )
    }
    
    func toUIModel() -> LostPet {
        return LostPet(from: toPet())
    }
}

// Альтернативный вариант - добавить инициализатор в LostPet
extension LostPet {
    // Инициализатор напрямую из APILostPet
    init(from apiPet: APILostPet) {
        let pet = apiPet.toPet()
        self.init(from: pet)
    }
}

// Тогда в APILostPet можно будет использовать:
extension APILostPet {
    func toUIModelAlternative() -> LostPet {
        return LostPet(from: self)
    }
}
