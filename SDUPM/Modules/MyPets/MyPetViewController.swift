//
//  MyPetViewController.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

import UIKit
import SnapKit

protocol IMyPetViewController: AnyObject {
    var myPetsArray: [MyPetModel] { get set }
    
    func showLoading()
    func hideLoading()
}


class MyPetViewController: UIViewController, IMyPetViewController {
    
    private let presenter = MyPetPresenter()
    
    var myPetsArray: [MyPetModel] = [] {
        didSet {
            collectionView.reloadData()
            emptyStackView.isHidden = !myPetsArray.isEmpty
            collectionView.isHidden = myPetsArray.isEmpty
        }
    }
    
    private lazy var emptyStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyImageView, emptyLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "eye.slash"))
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemGray
        imageView.frame.size = CGSize(width: 150, height: 150)
        return imageView
    }()
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No pets found"
        label.font = .systemFont(ofSize: 27, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Pet", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(addTaped), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        return button
    }()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.register(MyPetCell.self, forCellWithReuseIdentifier: MyPetCell.identifier)
        return cv
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        presenter.view = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        fetchData()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        
        view.addSubview(emptyStackView)
        emptyStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(46)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(addButton.snp.top).offset(-20)
        }
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func fetchData() {
        presenter.fetchData()
    }
    
    @objc private func addTaped() {
        presenter.createPet(from: self)
    }
    
    func showLoading() {
        emptyStackView.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        emptyStackView.isHidden = false
        activityIndicator.stopAnimating()
    }
}

extension MyPetViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        myPetsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPetCell.identifier, for: indexPath) as! MyPetCell
        cell.item = myPetsArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let cellWidth = collectionView.frame.width
            return CGSize(width: cellWidth, height: 90)
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MyPetDetailViewController(model: myPetsArray[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}
