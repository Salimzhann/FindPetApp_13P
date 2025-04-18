//
//  MainViewProtocol.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 18.04.2025.
//

import UIKit

protocol MainViewProtocol: AnyObject {
    var navigationController: UINavigationController? { get }
    
    func showLoading()
    func hideLoading()
    func updatePets(_ pets: [LostPet])
    func showError(message: String)
    func showMapView()
}
