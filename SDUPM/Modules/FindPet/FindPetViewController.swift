//
//  FindPetViewController.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

// File path: SDUPM/Modules/FindPet/FindPetViewController.swift

import UIKit
import SnapKit

class FindPetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IFindPetView {
    
    private var selectedImages: [UIImage] = []
    private let presenter = FindPetPresenter()
    
    private let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let uploadPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload Photo", for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGray4
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let speciesTextField = FindPetViewController.createTextField(placeholder: "Species (Dog, Cat)", required: true)
    private let colorTextField = FindPetViewController.createTextField(placeholder: "Color", required: true)
    private let genderTextField = FindPetViewController.createTextField(placeholder: "Gender (optional)")
    private let breedTextField = FindPetViewController.createTextField(placeholder: "Breed (optional)")
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search Pet", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .systemGreen
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Find a Pet"
        
        setupViews()
        setupActions()
        setupCollectionView()
        configurePresenter()
        hideKeyboardWhenTappedAround()
    }
    
    private func configurePresenter() {
        presenter.view = self
    }
    
    private func setupViews() {
        view.addSubview(uploadPhotoButton)
        uploadPhotoButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        view.addSubview(photoCollectionView)
        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(uploadPhotoButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        view.addSubview(speciesTextField)
        speciesTextField.snp.makeConstraints { make in
            make.top.equalTo(uploadPhotoButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        view.addSubview(colorTextField)
        colorTextField.snp.makeConstraints { make in
            make.top.equalTo(speciesTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        view.addSubview(genderTextField)
        genderTextField.snp.makeConstraints { make in
            make.top.equalTo(colorTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        view.addSubview(breedTextField)
        breedTextField.snp.makeConstraints { make in
            make.top.equalTo(genderTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        view.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions() {
        uploadPhotoButton.addTarget(self, action: #selector(uploadPhotoTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchPetTapped), for: .touchUpInside)
    }
    
    @objc private func uploadPhotoTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    @objc private func searchPetTapped() {
        guard let species = speciesTextField.text, !species.isEmpty,
              let color = colorTextField.text, !color.isEmpty,
              !selectedImages.isEmpty else {
            showErrorAlert(message: "Please upload a photo and fill in the required fields (Species and Color).")
            return
        }
        
        let gender = genderTextField.text?.isEmpty == true ? nil : genderTextField.text
        let breed = breedTextField.text?.isEmpty == true ? nil : breedTextField.text
        
        presenter.searchPet(
            photo: selectedImages.first!,
            species: species.lowercased(),
            color: color,
            gender: gender,
            breed: breed
        )
    }
    
    // MARK: - IFindPetView Implementation
    
    func showLoading() {
        activityIndicator.startAnimating()
        searchButton.isEnabled = false
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        searchButton.isEnabled = true
    }
    
    func navigateToSearchResults(response: PetSearchResponse) {
        let resultsVC = FoundPetViewController(searchResponse: response)
        navigationController?.pushViewController(resultsVC, animated: true)
    }
    
    func showError(message: String) {
        showErrorAlert(message: message)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            selectedImages = [selectedImage] // For this feature, we just use one image
            photoCollectionView.reloadData()
        }
        dismiss(animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
    }
    
    static func createTextField(placeholder: String, required: Bool = false, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        let placeholderText = required ? "\(placeholder) *" : placeholder
        textField.placeholder = placeholderText
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        textField.font = UIFont.systemFont(ofSize: 16)
        return textField
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension FindPetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.configure(with: selectedImages[indexPath.item])
        return cell
    }
}

// MARK: - Photo Cell
class PhotoCell: UICollectionViewCell {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
}
