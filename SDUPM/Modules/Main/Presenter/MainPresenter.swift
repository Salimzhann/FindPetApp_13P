//
//  MainPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

import UIKit

protocol IMainPresenter {
    func didTapDetail(id: String)
    func fetchLostPets(completion: @escaping ([LostPet]) -> Void)
}

class MainPresenter: IMainPresenter {
    
    private let provider = NetworkServiceProvider()
    weak var view: MainView?
    
    func didTapDetail(id: String) {
        // Так как теперь id - это строка, мы должны адаптировать код соответствующим образом
        // Здесь мы можем создать временный экземпляр PetDetailInformationViewController с id в виде строки
        // Или адаптировать PetDetailInformationViewController для работы со строковыми id
        
        // Для демонстрации попробуем преобразовать String id в Int
        if let numericId = Int(id) {
            let vc = PetDetailInformationViewController(id: numericId)
            vc.hidesBottomBarWhenPushed = true
            view?.navigationController?.pushViewController(vc, animated: true)
        } else {
            // Если id не может быть преобразовано в Int, показываем сообщение об ошибке
            let alert = UIAlertController(
                title: "Информация недоступна",
                message: "Детальная информация для данного питомца сейчас недоступна",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            view?.present(alert, animated: true)
        }
    }
    
    func fetchLostPets(completion: @escaping ([LostPet]) -> Void) {
        provider.fetchLostPets { pets in
            completion(pets)
        }
    }
}
