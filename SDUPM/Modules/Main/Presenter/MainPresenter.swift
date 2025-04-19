import UIKit

class MainPresenter: MainPresenterProtocol {
    
    private let provider = NetworkServiceProvider()
    weak var view: MainViewProtocol?
    
    func didTapDetail(id: Int) {
        print("MainPresenter: Opening pet details for id \(id)")
        // Используем новый MainPetDetailViewController вместо PetDetailInformationViewController
        let vc = MainPetDetailViewController(petId: id)
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
                    // Преобразуем APILostPet в LostPet
                    let lostPets = response.items.map { $0.toUIModel() }
                    print("MainPresenter: Fetched \(lostPets.count) lost pets")
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
                    print("MainPresenter: Fetched \(foundPets.count) found pets")
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
