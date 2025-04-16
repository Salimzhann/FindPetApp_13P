//
//  CreatePetViewController.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

// File path: SDUPM/Modules/MyPets/Submodule/CreatePetViewController.swift

import UIKit
import PhotosUI

class CreatePetViewController: UIViewController, UITextViewDelegate {
    
    private var selectedImages: [UIImage] = []
    private let presenter = CreatePetViewPresenter()
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add New Pet"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
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
        button.tintColor = .systemGray
        return button
    }()
    
    private let uploadPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        
        // Add camera icon
        let cameraImage = UIImage(systemName: "camera.fill")
        button.setImage(cameraImage, for: .normal)
        button.tintColor = .systemBlue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        return button
    }()
    
    // Form Fields
    private let nameField = createField(placeholder: "Pet Name", required: true)
    private let speciesField = createField(placeholder: "Species (Dog, Cat)", required: true)
    private let breedField = createField(placeholder: "Breed")
    private let ageField = createField(placeholder: "Age", keyboardType: .numberPad)
    private let colorField = createField(placeholder: "Color")
    private let genderField = createField(placeholder: "Gender")
    
    private let distinctiveFeaturesTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textView
    }()
    
    private let distinctiveFeaturesPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Distinctive features (optional)"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemGray3
        return label
    }()
    
    private let statusSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["At Home", "Lost"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Pet", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    // MARK: - Properties
    
    var onPetAdded: ((MyPetModel) -> Void)?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupViews()
        setupActions()
        setupCollectionView()
        setupTextView()
        hideKeyboardWhenTappedAround()
        
        // Connect presenter
        presenter.view = self
    }
    
    // MARK: - Setup Methods
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
            // Height will be determined by content
        }
    }
    
    private func setupViews() {
        // Title and back button
        contentView.addSubview(titleLabel)
        contentView.addSubview(backButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }
        
        // Photo selection
        contentView.addSubview(uploadPhotoButton)
        contentView.addSubview(photoCollectionView)
        
        uploadPhotoButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(16)
            make.width.equalTo(120)
            make.height.equalTo(100)
        }
        
        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(uploadPhotoButton)
            make.leading.equalTo(uploadPhotoButton.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }
        
        // Form fields
        let formFields = [
            createFormRow(label: "Name *", field: nameField),
            createFormRow(label: "Species *", field: speciesField),
            createFormRow(label: "Breed", field: breedField),
            createFormRow(label: "Age", field: ageField),
            createFormRow(label: "Color", field: colorField),
            createFormRow(label: "Gender", field: genderField)
        ]
        
        var lastView: UIView = photoCollectionView
        
        for (index, fieldView) in formFields.enumerated() {
            contentView.addSubview(fieldView)
            
            fieldView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(16)
                make.leading.trailing.equalToSuperview().inset(16)
            }
            
            lastView = fieldView
        }
        
        // Distinctive features
        contentView.addSubview(distinctiveFeaturesTextView)
        distinctiveFeaturesTextView.addSubview(distinctiveFeaturesPlaceholder)
        
        distinctiveFeaturesTextView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }
        
        distinctiveFeaturesPlaceholder.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(8)
        }
        
        // Status selector
        let statusLabel = UILabel()
        statusLabel.text = "Pet Status"
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        contentView.addSubview(statusLabel)
        contentView.addSubview(statusSegmentedControl)
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(distinctiveFeaturesTextView.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
        }
        
        statusSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        // Save button
        contentView.addSubview(saveButton)
        saveButton.addSubview(activityIndicator)
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(statusSegmentedControl.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(32) // Set the bottom constraint
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        uploadPhotoButton.addTarget(self, action: #selector(uploadPhotoTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(savePetTapped), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
    }
    
    private func setupTextView() {
        distinctiveFeaturesTextView.delegate = self
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == distinctiveFeaturesTextView {
            distinctiveFeaturesPlaceholder.isHidden = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == distinctiveFeaturesTextView && textView.text.isEmpty {
            distinctiveFeaturesPlaceholder.isHidden = false
        }
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func uploadPhotoTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5 // Max 5 images
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func savePetTapped() {
        // Validate required fields
        guard let name = nameField.text, !name.isEmpty,
              let species = speciesField.text, !species.isEmpty,
              !selectedImages.isEmpty else {
            
            showAlert(title: "Missing Information", message: "Please provide a name, species, and at least one photo.")
            return
        }
        
        // Get optional fields
        let breed = breedField.text
        let ageText = ageField.text
        let age = (ageText != nil && !ageText!.isEmpty) ? Int(ageText!) : nil
        let color = colorField.text
        let gender = genderField.text
        let distinctiveFeatures = distinctiveFeaturesTextView.text.isEmpty ? nil : distinctiveFeaturesTextView.text
        let status = statusSegmentedControl.selectedSegmentIndex == 0 ? "home" : "lost"
        
        // Show loading state
        saveButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        saveButton.isEnabled = false
        
        // Call presenter to create pet
        presenter.createPet(
            name: name,
            species: species,
            breed: breed,
            age: age,
            color: color,
            gender: gender,
            distinctiveFeatures: distinctiveFeatures,
            status: status,
            photos: selectedImages
        )
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Helpers
    
    private static func createField(placeholder: String, required: Bool = false, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        textField.placeholder = required ? "\(placeholder) *" : placeholder
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        return textField
    }
    
    private func createFormRow(label: String, field: UITextField) -> UIView {
        let containerView = UIView()
        
        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        containerView.addSubview(labelView)
        containerView.addSubview(field)
        
        labelView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        field.snp.makeConstraints { make in
            make.top.equalTo(labelView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        
        return containerView
    }
}

// MARK: - PHPickerViewControllerDelegate

extension CreatePetViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        let dispatchGroup = DispatchGroup()
        var newImages: [UIImage] = []
        
        for result in results {
            dispatchGroup.enter()
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                defer { dispatchGroup.leave() }
                
                if let image = object as? UIImage {
                    newImages.append(image)
                } else if let error = error {
                    print("Failed to load image: \(error.localizedDescription)")
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.selectedImages.append(contentsOf: newImages)
            self.photoCollectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension CreatePetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.configure(with: selectedImages[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Show options to remove photo
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Remove Photo", style: .destructive) { _ in
            self.selectedImages.remove(at: indexPath.item)
            self.photoCollectionView.deleteItems(at: [indexPath])
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - CreatePetViewDelegate

extension CreatePetViewController: CreatePetViewDelegate {
    func petCreated(pet: MyPetModel) {
        onPetAdded?(pet)
        dismiss(animated: true)
    }
    
    func showError(message: String) {
        saveButton.setTitle("Save Pet", for: .normal)
        activityIndicator.stopAnimating()
        saveButton.isEnabled = true
        
        showAlert(title: "Error", message: message)
    }
}

// MARK: - Photo Cell

class PhotoCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let deleteButton = UIButton(type: .system)
    
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
