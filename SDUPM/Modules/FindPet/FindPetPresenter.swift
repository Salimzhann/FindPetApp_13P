//
//  FindPetPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 08.04.2025.
//

// File path: SDUPM/Modules/FindPet/FindPetPresenter.swift

import UIKit
import CoreLocation

protocol IFindPetPresenter {
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, isFindingOwner: Bool, coordinates: CLLocationCoordinate2D?)
}

class FindPetPresenter: IFindPetPresenter {
    
    private let provider = NetworkServiceProvider()
    weak var view: IFindPetView?
    
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, isFindingOwner: Bool = false, coordinates: CLLocationCoordinate2D? = nil) {
        view?.showLoading()
        
        var coordX: Double? = nil
        var coordY: Double? = nil
        
        // Add coordinates if finding owner and coordinates are available
        if isFindingOwner, let location = coordinates {
            coordX = location.longitude
            coordY = location.latitude
        }
        
        provider.searchPet(
            photo: photo,
            species: species,
            color: color,
            gender: gender,
            breed: breed,
            coordX: coordX,
            coordY: coordY
        ) { [weak self] result in
            switch result {
            case .success(let response):
                self?.view?.hideLoading()
                self?.view?.navigateToSearchResults(response: response)
                
            case .failure(let error):
                self?.view?.hideLoading()
                self?.view?.showError(message: "Search failed: \(error.localizedDescription)")
            }
        }
    }
}
