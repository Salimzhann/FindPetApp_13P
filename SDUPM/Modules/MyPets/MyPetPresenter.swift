//
//  MyPetPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

import UIKit


class MyPetPresenter {
    
    weak var view: IMyPetViewController?
    private let provider = NetworkServiceProvider()
    
    func fetchData() {
        view?.showLoading()
//        provider.fetchUserPets { [weak self] data in
//            if let data = data {
//                print("good thing")
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                    self?.view?.myPetsArray = data
//                    self?.view?.hideLoading()
//                }
//            } else {
//                print("False thing")
//            }
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.view?.hideLoading()
        }
    }
    
    func createPet(from view: UIViewController) {
        let vc = CreatePetViewController()
        vc.modalPresentationStyle = .fullScreen // Открытие на весь экран
        vc.modalTransitionStyle = .coverVertical // Анимация снизу вверх
        view.present(vc, animated: true)
        
        vc.onPetAdded = { [weak self] data in
            self?.view?.myPetsArray.append(data)
//            self?.fetchData()
        }
    }
}
