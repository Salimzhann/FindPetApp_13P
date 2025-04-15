//
//  FindPetPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 08.04.2025.
//

import UIKit

protocol IFindPetPresenter {
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?)
}

protocol IFindPetView: AnyObject {
    func showLoading()
    func hideLoading()
    func navigateToSearchResults(response: PetSearchResponse)
    func showError(message: String)
}

class FindPetPresenter: IFindPetPresenter {
    
    private let provider = NetworkServiceProvider()
    weak var view: IFindPetView?
    
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?) {
        view?.showLoading()
        
        provider.searchPet(photo: photo, species: species, color: color, gender: gender, breed: breed) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                
                switch result {
                case .success(let response):
                    self?.view?.navigateToSearchResults(response: response)
                case .failure(let error):
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
}
