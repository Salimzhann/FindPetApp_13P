// Путь: SDUPM/Modules/MyPets/Submodule/EditPetViewPresenter.swift

import UIKit

class EditPetViewPresenter {
    
    private let provider = NetworkServiceProvider()
    weak var view: EditPetViewDelegate?
    
    func updatePet(
        id: Int,
        name: String,
        species: String,
        breed: String?,
        age: Int?,
        color: String?,
        gender: String?,
        distinctiveFeatures: String?,
        status: String
    ) {
        provider.updatePet(
            petId: id,
            name: name,
            species: species,
            breed: breed,
            age: age,
            color: color,
            gender: gender,
            distinctiveFeatures: distinctiveFeatures,
            status: status
        ) { [weak self] result in
            switch result {
            case .success(let updatedPet):
                // Создаем MyPetModel из обновленных данных
                let ageStr = updatedPet.age != nil ? String(updatedPet.age!) : "0"
                let petModel = MyPetModel(
                    id: updatedPet.id,
                    name: updatedPet.name,
                    species: updatedPet.species,
                    breed: updatedPet.breed ?? "",
                    age: ageStr,
                    color: updatedPet.color ?? "",
                    images: [], // Существующие изображения сохраняем отдельно
                    status: updatedPet.status,
                    description: updatedPet.distinctive_features ?? "",
                    gender: updatedPet.gender ?? "",
                    photoURLs: updatedPet.photos.map { $0.photo_url },
                    lastSeenLocation: updatedPet.last_seen_location,
                    lostDate: updatedPet.lost_date
                )
                
                DispatchQueue.main.async {
                    self?.view?.petUpdated(pet: petModel)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.view?.showError(message: "Failed to update pet: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updatePetStatus(id: Int, status: String, completion: @escaping (Result<MyPetModel, Error>) -> Void) {
        provider.updatePet(
            petId: id,
            status: status
        ) { result in
            switch result {
            case .success(let updatedPet):
                // Создаем MyPetModel из обновленных данных
                let ageStr = updatedPet.age != nil ? String(updatedPet.age!) : "0"
                let petModel = MyPetModel(
                    id: updatedPet.id,
                    name: updatedPet.name,
                    species: updatedPet.species,
                    breed: updatedPet.breed ?? "",
                    age: ageStr,
                    color: updatedPet.color ?? "",
                    images: [], // Существующие изображения сохраняем отдельно
                    status: updatedPet.status,
                    description: updatedPet.distinctive_features ?? "",
                    gender: updatedPet.gender ?? "",
                    photoURLs: updatedPet.photos.map { $0.photo_url },
                    lastSeenLocation: updatedPet.last_seen_location,
                    lostDate: updatedPet.lost_date
                )
                
                DispatchQueue.main.async {
                    completion(.success(petModel))
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Delete Pet
    
    func deletePet(petId: Int) {
        provider.deletePet(petId: petId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.view?.petDeleted(petId: petId)
                case .failure(let error):
                    self?.view?.showError(message: "Failed to delete pet: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Versión mejorada para soportar callback
    func deletePet(petId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.deletePet(petId: petId) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
