//
//  MainPresenterProtocol.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 18.04.2025.
//

import Foundation

protocol MainPresenterProtocol: AnyObject {
    func fetchLostPets()
    func fetchFoundPets()
    func didTapDetail(id: Int)
    func showMap()
}
