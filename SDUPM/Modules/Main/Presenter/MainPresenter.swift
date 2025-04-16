//
//  MainPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

import UIKit


class MainPresenter {
    
    private let provider = NetworkServiceProvider()
    weak var view: MainView?
    
    func didTapDetail(id: Int) {
        let vc = PetDetailInformationViewController(id: id)
        vc.hidesBottomBarWhenPushed = true
        view?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func receiveData(completion: @escaping ([LostPet]) -> Void) {
        provider.fetchLostPets(completion: completion)
    }
}
