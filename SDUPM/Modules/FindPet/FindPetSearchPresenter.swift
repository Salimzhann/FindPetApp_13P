// Path: SDUPM/Modules/FindPet/FindPetSearchPresenter.swift

import UIKit
import CoreLocation

protocol IFindPetSearchPresenter {
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, isFindingOwner: Bool)
    func reportFoundPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, location: CLLocationCoordinate2D?)
}

class FindPetSearchPresenter: IFindPetSearchPresenter {
    
    private let provider = NetworkServiceProvider()
    weak var view: IFindPetView?
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, isFindingOwner: Bool = false) {
        view?.showLoading()
        
        // Check if we're finding owner (this would typically include location in a real implementation)
        let coordX: Double? = nil
        let coordY: Double? = nil
        
        provider.searchPet(
            photo: photo,
            species: species,
            color: color,
            gender: gender,
            breed: breed,
            coordX: coordX,
            coordY: coordY,
            save: false, // Не сохраняем при поиске
            completion: { [weak self] (result: Result<PetSearchResponse, Error>) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    
                    switch result {
                    case .success(let response):
                        self.view?.navigateToSearchResults(response: response)
                        
                    case .failure(let error):
                        self.view?.showError(message: "Search failed: \(error.localizedDescription)")
                    }
                }
            }
        )
    }
    
    func reportFoundPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, location: CLLocationCoordinate2D?) {
        view?.showLoading()
        
        let coordX = location?.longitude
        let coordY = location?.latitude
        
        provider.searchPet(
            photo: photo,
            species: species,
            color: color,
            gender: gender,
            breed: breed,
            coordX: coordX,
            coordY: coordY,
            save: true, // Важно: здесь мы сохраняем найденное животное в базу данных
            completion: { [weak self] (result: Result<PetSearchResponse, Error>) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    
                    switch result {
                    case .success(_):
                        self.view?.showSuccess(message: "Pet successfully added to found list.")
                    case .failure(let error):
                        self.view?.showError(message: "Failed to add pet: \(error.localizedDescription)")
                    }
                }
            }
        )
    }

}
