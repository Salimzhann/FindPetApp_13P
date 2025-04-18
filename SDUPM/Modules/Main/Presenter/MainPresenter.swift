import UIKit

class MainPresenter: MainPresenterProtocol {
    
    private let provider = NetworkServiceProvider()
    weak var view: MainViewProtocol?
    
    func didTapDetail(id: Int) {
        let vc = PetDetailInformationViewController(id: id)
        vc.hidesBottomBarWhenPushed = true
        view?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchLostPets() {
        view?.showLoading()
        
        provider.fetchLostPets { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                
                switch result {
                case .success(let response):
                    let lostPets = response.items.map { LostPet(from: $0) }
                    self?.view?.updatePets(lostPets)
                case .failure(let error):
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    func fetchFoundPets() {
        view?.showLoading()
        
        provider.fetchFoundPets { [weak self] pets, error in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                
                if let pets = pets {
                    let foundPets = pets.map { LostPet(from: $0) }
                    self?.view?.updatePets(foundPets)
                } else if let error = error {
                    self?.view?.showError(message: error.localizedDescription)
                } else {
                    self?.view?.showError(message: "Failed to fetch found pets")
                }
            }
        }
    }
    
    func showMap() {
        view?.showMapView()
    }
}
