//
//  FindPetPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 08.04.2025.
//

// File path: SDUPM/Modules/FindPet/FindPetPresenter.swift

import UIKit

protocol IFindPetPresenter {
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?)
}

class FindPetPresenter: IFindPetPresenter {
    
    private let provider = NetworkServiceProvider()
    weak var view: IFindPetView?
    
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?) {
        view?.showLoading()
        
        provider.searchPet(photo: photo, species: species, color: color, gender: gender, breed: breed) { [weak self] result in
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
