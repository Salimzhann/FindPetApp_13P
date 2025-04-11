//
//  FindPetPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 08.04.2025.
//

import Foundation

protocol IFindPetPresenter {
    func searchPetTapped()
}


class FindPetPresenter: IFindPetPresenter {
    
    private let provider = NetworkServiceProvider()
    
    func searchPetTapped() {
        
    }
}
