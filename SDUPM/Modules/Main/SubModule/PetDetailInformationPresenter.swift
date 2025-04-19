// Путь: SDUPM/Modules/Main/SubModule/PetDetailPresenter.swift

import Foundation

class PetDetailPresenter {
    weak var view: PetDetailViewProtocol?
    private let provider = NetworkServiceProvider()
    
    // Временно используем моковые данные, пока не реализуем API
    private var mockPets: [Pet] = [
        Pet(
            id: 1,
            name: "Buddy",
            species: "dog",
            breed: "Labrador Retriever",
            age: 3,
            color: "Golden",
            gender: "male",
            distinctive_features: "White spot on chest, blue collar",
            last_seen_location: "Central Park",
            photos: [
                PetPhoto(
                    id: 101,
                    pet_id: 1,
                    photo_url: "https://www.thesprucepets.com/thmb/hxWjs7evF2hP1Fb1c1HAvRi_Rw0=/2765x0/filters:no_upscale():strip_icc()/chinese-dog-breeds-4797219-hero-2a1e9c5ed2c54d00aef75b05c5db399c.jpg",
                    is_primary: true,
                    created_at: "2025-04-15T06:42:08.087996"
                ),
                PetPhoto(
                    id: 102,
                    pet_id: 1,
                    photo_url: "https://i2-prod.getsurrey.co.uk/news/real-life/article31159093.ece/ALTERNATES/s1200d/0_Cute-Labrador-retriever-looking-at-camera.jpg",
                    is_primary: false,
                    created_at: "2025-04-15T06:42:10.087996"
                )
            ],
            status: "lost",
            created_at: "2025-04-15T06:42:07",
            updated_at: "2025-04-15T06:42:07",
            lost_date: "2025-04-14T18:30:00.000000",
            owner_id: 1
        ),
        Pet(
            id: 2,
            name: "Luna",
            species: "cat",
            breed: "Siamese",
            age: 2,
            color: "Cream with brown markings",
            gender: "female",
            distinctive_features: "Blue eyes, red collar with bell",
            last_seen_location: "Near 5th Avenue",
            photos: [
                PetPhoto(
                    id: 201,
                    pet_id: 2,
                    photo_url: "https://www.tippaws.com/cdn/shop/articles/getting-to-know-your-bengal-cat-tippaws.png?v=1729077812",
                    is_primary: true,
                    created_at: "2025-04-15T06:43:09.349109"
                ),
                PetPhoto(
                    id: 202,
                    pet_id: 2,
                    photo_url: "https://cdn-prd.content.metamorphosis.com/wp-content/uploads/sites/2/2022/09/shutterstock_588477563-1.jpg",
                    is_primary: false,
                    created_at: "2025-04-15T06:43:11.349109"
                )
            ],
            status: "lost",
            created_at: "2025-04-15T06:43:09",
            updated_at: "2025-04-15T06:43:09",
            lost_date: "2025-04-12T14:15:00.000000",
            owner_id: 2
        ),
        Pet(
            id: 3,
            name: "Max",
            species: "dog",
            breed: "German Shepherd",
            age: 4,
            color: "Black and tan",
            gender: "male",
            distinctive_features: "Short tail, green collar",
            last_seen_location: "Downtown",
            photos: [
                PetPhoto(
                    id: 301,
                    pet_id: 3,
                    photo_url: "https://cdn.britannica.com/79/232779-050-6B0411D7/German-Shepherd-dog-Alsatian.jpg",
                    is_primary: true,
                    created_at: "2025-04-15T09:52:19.053884"
                ),
                PetPhoto(
                    id: 302,
                    pet_id: 3,
                    photo_url: "https://cdn.shopify.com/s/files/1/1831/0741/files/pettsie-awesome-facts-about-German-Shepherds.jpg?v=1623746710",
                    is_primary: false,
                    created_at: "2025-04-15T09:52:22.053884"
                )
            ],
            status: "found",
            created_at: "2025-04-15T09:52:18",
            updated_at: "2025-04-15T09:52:18",
            lost_date: nil,
            owner_id: 3
        )
    ]
    
    // В будущем это будет заменено на реальный API вызов
    func fetchPetDetails(id: Int) {
        print("PetDetailPresenter: Fetching pet details for id \(id)")
        
        // Добавляем тестовые данные с дополнительными id
        addTestPets()
        
        // Создаем имитацию задержки для загрузки данных
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Находим питомца по ID из наших мок-данных
            if let pet = self.mockPets.first(where: { $0.id == id }) {
                print("PetDetailPresenter: Found pet with id \(id): \(pet.name)")
                DispatchQueue.main.async {
                    self.view?.displayPetDetails(pet)
                }
            } else {
                print("PetDetailPresenter: Pet with id \(id) not found!")
                // Даже если не нашли нужного питомца, покажем первого доступного для тестирования
                if !self.mockPets.isEmpty {
                    print("PetDetailPresenter: Using first available pet instead")
                    DispatchQueue.main.async {
                        self.view?.displayPetDetails(self.mockPets[0])
                    }
                } else {
                    DispatchQueue.main.async {
                        self.view?.showError("Pet details not found")
                    }
                }
            }
        }
    }
    
    // Метод для добавления тестовых данных
    private func addTestPets() {
        // Копируем существующих питомцев с новыми id
        var additionalPets: [Pet] = []
        
        // Создаем копии с id от 4 до 20 для тестирования
        for i in 4...20 {
            // Пропускаем, если питомец с таким id уже существует
            if mockPets.contains(where: { $0.id == i }) {
                continue
            }
            
            // Берем случайного питомца из существующих для основы
            let basePet = mockPets[Int.random(in: 0..<mockPets.count)]
            
            // Создаем нового питомца с тем же basePet, но другим id и именем
            let newPet = Pet(
                id: i,
                name: "Test Pet \(i)",
                species: basePet.species,
                breed: basePet.breed,
                age: basePet.age,
                color: basePet.color,
                gender: basePet.gender,
                distinctive_features: basePet.distinctive_features,
                last_seen_location: basePet.last_seen_location,
                photos: basePet.photos,
                status: basePet.status,
                created_at: basePet.created_at,
                updated_at: basePet.updated_at,
                lost_date: basePet.lost_date,
                owner_id: basePet.owner_id
            )
            
            additionalPets.append(newPet)
        }
        
        // Добавляем новых питомцев в коллекцию
        mockPets.append(contentsOf: additionalPets)
    }
}
