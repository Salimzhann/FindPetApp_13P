//
//  MyPetPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

// File path: SDUPM/Modules/MyPets/MyPetPresenter.swift

// File path: SDUPM/Modules/MyPets/MyPetPresenter.swift

import UIKit

protocol IMyPetPresenter {
    func fetchUserPets()
    func createPet(from view: UIViewController)
    func downloadPetImages(for pet: MyPetModel, completion: @escaping (MyPetModel) -> Void)
}

class MyPetPresenter: IMyPetPresenter {
    
    weak var view: IMyPetViewController?
    private let provider = NetworkServiceProvider()
    
    // INSTRUCTIONS:
    // Replace the ENTIRE existing fetchUserPets method with this implementation,
    // Don't add it as a second method

    // In MyPetPresenter.swift:

    // Replace this method:
    func fetchUserPets() {
        // Ensure UI updates happen on main thread
        DispatchQueue.main.async { [weak self] in
            self?.view?.showLoading()
        }
        
        provider.fetchUserPets { [weak self] petsResponse in
            guard let self = self else { return }
            
            if let petsResponse = petsResponse {
                var pets = petsResponse.map { $0.toMyPetModel() }
                
                let group = DispatchGroup()
                
                // Load images for each pet
                for (index, pet) in pets.enumerated() {
                    group.enter()
                    self.downloadPetImages(for: pet) { updatedPet in
                        pets[index] = updatedPet
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    // This is already on the main thread
                    self.view?.myPetsArray = pets
                    self.view?.hideLoading()
                }
            } else {
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    self.view?.showError(message: "Could not load your pets. Please try again later.")
                }
            }
        }
    }

    // MARK: - Image Loading
    
    func downloadPetImages(for pet: MyPetModel, completion: @escaping (MyPetModel) -> Void) {
        let group = DispatchGroup()
        var images: [UIImage] = []
        
        for urlString in pet.photoURLs {
            group.enter()
            
            guard let url = URL(string: urlString) else {
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                
                if let data = data, let image = UIImage(data: data) {
                    images.append(image)
                } else if let placeholderImage = UIImage(systemName: "photo") {
                    // Use a placeholder if image loading fails
                    images.append(placeholderImage)
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            // If no images were loaded, use a placeholder
            if images.isEmpty, let placeholderImage = UIImage(systemName: "photo") {
                images.append(placeholderImage)
            }
            
            // Choose ONE of these approaches:
            
            // Option 1: If 'images' is a var property in MyPetModel
            var updatedPet = pet
            updatedPet.images = images
            completion(updatedPet)
            
            // Option 2: If using the withImages helper method
            // let updatedPet = pet.withImages(images)
            // completion(updatedPet)
        }
    }
    
    func createPet(from view: UIViewController) {
        let vc = CreatePetViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        vc.onPetAdded = { [weak self] newPet in
            self?.view?.myPetsArray.append(newPet)
            // No need to call fetchUserPets again as we've already added the pet to the array
        }
        view.present(vc, animated: true)
    }
}
