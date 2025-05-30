//
//  MyPetDetailPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 12.04.2025.
//

import Foundation


class MyPetDetailPresenter {
    weak var view: MyPetDetailViewController?
    
    func editDidTap(model: MyPetModel) {
        view?.navigationController?.pushViewController(EditPetViewController(item: model), animated: true)
    }
}
