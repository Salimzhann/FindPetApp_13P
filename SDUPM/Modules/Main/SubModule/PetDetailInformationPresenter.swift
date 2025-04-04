//
//  PetDetailInformationPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

import UIKit

protocol IPetDetailInformationPresenter {
    func sendRequest(id: Int)
    func callTaped(number: String)
}


class PetDetailInformationPresenter: IPetDetailInformationPresenter {
    
    private let provider = NetworkServiceProvider()
    weak var view: IPetDetailInformationViewController?
    
    func sendRequest(id: Int) {
        provider.petDetailInfo(id: id) { [weak self] data in
            self?.view?.detailInfo = data
        }
    }
    
    func callTaped(number: String) {
        if let url = URL(string: "tel://\(number)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("❌ Can't make a call on this device")
            }
        }
    }
    
}
