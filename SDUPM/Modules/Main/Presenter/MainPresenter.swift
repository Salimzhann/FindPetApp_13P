import UIKit

class MainPresenter: MainPresenterProtocol {
    
    private let provider = NetworkServiceProvider()
    weak var view: MainViewProtocol?
    
    // Сохраняем текущие данные животных
    private var currentPets: [Pet] = []
    
    func didTapDetail(id: Int) {
        print("MainPresenter: Opening pet details for id \(id)")
        
        // Ищем животное с нужным ID в текущих данных
        if let pet = currentPets.first(where: { $0.id == id }) {
            print("MainPresenter: Found pet with id \(id) in current data")
            let vc = MainPetDetailViewController(pet: pet)
            vc.hidesBottomBarWhenPushed = true
            view?.navigationController?.pushViewController(vc, animated: true)
        } else {
            print("MainPresenter: Pet with id \(id) not found in current data")
            let vc = MainPetDetailViewController(petId: id)
            vc.hidesBottomBarWhenPushed = true
            view?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func fetchLostPets() {
        view?.showLoading()
        
        provider.fetchLostPets { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                
                switch result {
                case .success(let response):
                    // Просто сохраняем полученные данные
                    self?.currentPets = response.items
                    
                    // Преобразуем Pet в LostPet только для отображения в UI
                    let lostPets = response.items.map { LostPet(from: $0) }
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
                    // Сохраняем исходные объекты Pet
                    self?.currentPets = pets
                    
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
