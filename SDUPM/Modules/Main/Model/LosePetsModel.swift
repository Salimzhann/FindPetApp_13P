import Foundation

struct LostPetResponse: Codable {
    let items: [Pet]
    let total: Int?
}

struct LostPet: Codable {
    let id: Int
    let name: String
    let age: Int?
    let gender: String?
    let species: String
    let imageUrl: String?
    
    init(from pet: Pet) {
        self.id = pet.id
        self.name = pet.name
        self.age = pet.age
        self.gender = pet.gender
        self.species = pet.species
        self.imageUrl = pet.photos.first(where: { $0.is_primary })?.photo_url ?? pet.photos.first?.photo_url
    }
    
    init(id: Int, name: String, age: Int?, gender: String?, species: String, imageUrl: String?) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.species = species
        self.imageUrl = imageUrl
    }
}
