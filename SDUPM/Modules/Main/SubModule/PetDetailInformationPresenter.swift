// Путь: SDUPM/Modules/Main/SubModule/PetDetailPresenter.swift

import Foundation

class PetDetailPresenter {
    weak var view: PetDetailViewProtocol?
    private let provider = NetworkServiceProvider()
    
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
