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
            tableView.reloadData()
            emptyStackView.isHidden = !myPetsArray.isEmpty
            tableView.isHidden = myPetsArray.isEmpty
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
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.register(MyPetCell.self, forCellReuseIdentifier: MyPetCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        presenter.view = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
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
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(addButton.snp.top).offset(-20)
        }
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
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
    
    @objc private func refreshData() {
        presenter.fetchData()
        refreshControl.endRefreshing()
    }
}

extension MyPetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myPetsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyPetCell.identifier, for: indexPath) as! MyPetCell
        cell.item = myPetsArray[indexPath.row]
        return cell
    }
}
