//
//  PetDetailInformationViewController.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

import UIKit
import SnapKit

protocol IPetDetailInformationViewController: AnyObject {
    var detailInfo: PetDetailInfoModel? { get set }
}

class PetDetailInformationViewController: UIViewController, IPetDetailInformationViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    private let ageLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private let breedLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private let genderLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private let phoneButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Позвонить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(callTaped), for: .touchUpInside)
        return button
    }()
    
    private let presenter = PetDetailInformationPresenter()
    
    private let id: Int
    private var phone: String = ""
    
    var detailInfo: PetDetailInfoModel? = nil {
        didSet {
            
        }
    }
    
    init(id: Int) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        setupUI()
        presenter.view = self
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemGreen
    }
    
    private func fetchData() {
        presenter.sendRequest(id: id)
    }
    @objc private func callTaped() {
        presenter.callTaped(number: phone)
    }
}
