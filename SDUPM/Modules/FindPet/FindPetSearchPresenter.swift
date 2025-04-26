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
            completion: { [weak self] (result: Result<PetSearchResponse, Error>) in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.view?.hideLoading()
                    self.view?.navigateToSearchResults(response: response)
                    
                case .failure(let error):
                    self.view?.hideLoading()
                    self.view?.showError(message: "Search failed: \(error.localizedDescription)")
                }
            }
        )
    }
    
    func reportFoundPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, location: CLLocationCoordinate2D?) {
        view?.showLoading()
        
        let coordX = location?.longitude
        let coordY = location?.latitude
        
        provider.reportFoundPet(
            photo: photo,
            species: species,
            color: color,
            gender: gender,
            breed: breed,
            coordinates: location,
            completion: { [weak self] (result: Result<Void, Error>) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    
                    switch result {
                    case .success:
                        self.view?.showSuccess(message: "Pet successfully added to found list.")
                    case .failure(let error):
                        self.view?.showError(message: "Failed to add pet: \(error.localizedDescription)")
                    }
                }
            }
        )
    }
}
