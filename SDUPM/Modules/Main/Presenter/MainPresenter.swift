import UIKit

class MainPresenter: MainPresenterProtocol {
    
    private let provider = NetworkServiceProvider()
    weak var view: MainViewProtocol?
    
    // Сохраняем текущие данные животных
    private var currentPets: [Pet] = []
    // Флаг для отслеживания текущего режима просмотра (Lost или Found)
    private var isFoundMode = false
    
    func didTapDetail(id: Int) {
        print("MainPresenter: Opening pet details for id \(id)")
        
        // Создаем и показываем контроллер с детальной информацией в зависимости от текущего режима
        if isFoundMode {
            // Для режима Found используем API запрос для получения Found Pet
            provider.getFoundPetDetails(petId: id) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let pet):
                        print("MainPresenter: Successfully fetched found pet details for id \(id)")
                        // Используем LostPetDetailViewController для отображения найденного питомца
                        let vc = LostPetDetailViewController(withPet: pet)
                        vc.hidesBottomBarWhenPushed = true
                        self?.view?.navigationController?.pushViewController(vc, animated: true)
                        
                    case .failure(let error):
                        print("MainPresenter: Failed to fetch found pet details: \(error.localizedDescription)")
                        self?.view?.showError(message: "Failed to load pet details: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Для режима Lost используем уже существующую логику
            let vc = LostPetDetailViewController(withPetId: id)
            vc.hidesBottomBarWhenPushed = true
            view?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func fetchLostPets() {
        view?.showLoading()
        isFoundMode = false
        
        provider.fetchLostPets { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                
                switch result {
                case .success(let response):
                    // Сохраняем полученные данные
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
        isFoundMode = true
        
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
