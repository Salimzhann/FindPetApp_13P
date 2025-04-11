//
//  ProfilePresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 11.04.2025.
//

import UIKit


class ProfilePresenter {
    
    weak var view: ProfileView?
    
    private let provider = NetworkServiceProvider()
    
    func fetchProfile() {
        view?.showLoading()
        provider.fetchUserProfile { [weak self] model in
            guard let model = model else {
                return
            }
            DispatchQueue.main.async {
                self?.view?.configure(model: model)
                self?.view?.hideLoading()
            }
        }
    }
}
