//
//  CreatePetViewPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 02.04.2025.
//
// File path: SDUPM/Modules/MyPets/Submodule/CreatePetViewPresenter.swift

import UIKit

protocol CreatePetViewDelegate: AnyObject {
    func petCreated(pet: MyPetModel)
    func showError(message: String)
}

class CreatePetViewPresenter {
    
    private let provider = NetworkServiceProvider()
    weak var view: CreatePetViewDelegate?
    
    func createPet(name: String, species: String, breed: String?, age: Int?, color: String?, gender: String?, distinctiveFeatures: String?, status: String, photos: [UIImage]) {
        
        provider.createPet(
            name: name,
            species: species,
            breed: breed,
            age: age,
            color: color,
            gender: gender,
            distinctiveFeatures: distinctiveFeatures,
            photos: photos
        ) { [weak self] result in
            switch result {
            case .success(let petResponse):
                // Create a MyPetModel from the API response
                let pet = MyPetModel(
                    id: petResponse.id,
                    name: petResponse.name,
                    species: petResponse.species,
                    breed: petResponse.breed ?? "",
                    age: String(petResponse.age ?? 0),
                    images: photos, // We already have the images locally
                    status: status,
                    description: petResponse.distinctive_features ?? "",
                    gender: petResponse.gender ?? "",
                    photoURLs: petResponse.photos.map { $0.photo_url },
                    lastSeenLocation: petResponse.last_seen_location,
                    lostDate: petResponse.lost_date
                )
                
                DispatchQueue.main.async {
                    self?.view?.petCreated(pet: pet)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.view?.showError(message: "Failed to create pet: \(error.localizedDescription)")
                }
            }
        }
    }
}
