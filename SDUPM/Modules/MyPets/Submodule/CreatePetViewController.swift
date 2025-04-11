//
//  CreatePetViewController.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

import UIKit
import PhotosUI


class CreatePetViewController: UIViewController, UITextViewDelegate {
    
    private var selectedImages: [UIImage] = []
    private let presenter = CreatePetViewPresenter()
    
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
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray4
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.snp.makeConstraints { make in
            make.size.equalTo(30)
        }
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    private let uploadPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload Photo", for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGray4
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let nameTextField = CreatePetViewController.createTextField(placeholder: "Pet Name")
    private let categoryTextField = CreatePetViewController.createTextField(placeholder: "Category (Dog, Cat)")
    private let ageTextField = CreatePetViewController.createTextField(placeholder: "Age", keyboardType: .decimalPad)
    private let breedTextField = CreatePetViewController.createTextField(placeholder: "Breed")
    private let colorTextField = CreatePetViewController.createTextField(placeholder: "Color")
    private let genderTextField = CreatePetViewController.createTextField(placeholder: "Gender")
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Description"
        textView.textColor = .lightGray
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.keyboardType = .default
        textView.returnKeyType = .done
        textView.isScrollEnabled = true
        return textView
    }()
    
    var onPetAdded: (() -> Void)?
    
    private let statusSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Not Lost", "Lost"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Pet", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        setupActions()
        setupCollectionView()
        descriptionTextView.delegate = self
    }
    
    private func setupViews() {
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.size.equalTo(30)
        }
        
        view.addSubview(uploadPhotoButton)
        uploadPhotoButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        view.addSubview(photoCollectionView)
        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.equalTo(uploadPhotoButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(uploadPhotoButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        view.addSubview(categoryTextField)
        categoryTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        view.addSubview(breedTextField)
        breedTextField.snp.makeConstraints { make in
            make.top.equalTo(categoryTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        view.addSubview(ageTextField)
        ageTextField.snp.makeConstraints { make in
            make.top.equalTo(breedTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        view.addSubview(colorTextField)
        colorTextField.snp.makeConstraints { make in
            make.top.equalTo(ageTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        view.addSubview(genderTextField)
        genderTextField.snp.makeConstraints { make in
            make.top.equalTo(colorTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        view.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(genderTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(90)
        }
        
        view.addSubview(statusSegmentedControl)
        statusSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(250)
        }
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-50)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(46)
        }
    }
    
    private func setupActions() {
        uploadPhotoButton.addTarget(self, action: #selector(uploadPhotoTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(savePetTapped), for: .touchUpInside)
    }
    
    @objc private func uploadPhotoTapped() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5 // Максимум 5 изображений
        configuration.filter = .images // Только изображения

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func savePetTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let age = ageTextField.text, !age.isEmpty,
              let breed = breedTextField.text, !breed.isEmpty,
              let category = categoryTextField.text, !category.isEmpty,
              let gender = genderTextField.text, !gender.isEmpty,
              let color = colorTextField.text, !color.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty,
              !selectedImages.isEmpty else {
            showErrorAlert(message: "Заполните все поля и добавьте хотя бы одно фото!")
            return
        }
        
        presenter.uploadPetData(
            name: name,
            age: age,
            breed: breed,
            category: category,
            isLost: statusSegmentedControl.selectedSegmentIndex == 1,
            images: selectedImages
        ) { success in
            if success {
                self.onPetAdded?()
                self.dismiss(animated: true)
            } else {
                self.showErrorAlert(message: "Ошибка при загрузке данных питомца")
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }

    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = .lightGray
        }
    }
    
    private static func createTextField(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.layer.cornerRadius = 16
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        return textField
    }
}

extension CreatePetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = UIImageView(image: selectedImages[indexPath.item])
        imageView.frame = cell.bounds
        cell.layer.cornerRadius = 12
        cell.addSubview(imageView)
        return cell
    }
}


extension CreatePetViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var newImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()  // Create a dispatch group to track async operations
        
        for result in results {
            dispatchGroup.enter()  // Enter the group for each async operation
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    newImages.append(image)
                }
                
                dispatchGroup.leave()  // Leave the group when the image loading is done
            }
        }
        
        // When all images have been loaded, update the selectedImages array and reload the collection view
        dispatchGroup.notify(queue: .main) {
            self.selectedImages.append(contentsOf: newImages)
            self.photoCollectionView.reloadData()
        }
        
        dismiss(animated: true)
    }
}
