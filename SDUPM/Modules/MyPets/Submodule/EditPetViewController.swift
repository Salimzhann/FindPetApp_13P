// Путь: SDUPM/Modules/MyPets/Submodule/EditPetViewController.swift

import UIKit
import SnapKit

class EditPetViewController: UIViewController, UITextViewDelegate {
    
    private var pet: MyPetModel
    private let presenter = EditPetViewPresenter()
    
    weak var delegate: EditPetViewDelegate?
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Pet"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    private let nameField = UITextField()
    private let speciesField = UITextField()
    private let breedField = UITextField()
    private let ageField = UITextField()
    private let colorField = UITextField()
    private let genderField = UITextField()
    
    private let distinctiveFeaturesTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textView
    }()
    
    private let distinctiveFeaturesPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Distinctive features (optional)"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray3
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Pet Status"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let statusSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["At Home", "Lost"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Pet", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Pet", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(pet: MyPetModel) {
        self.pet = pet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        fillFormWithPetData()
        setupPresenter()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
        
        // Настройка полей
        nameField.placeholder = "Pet Name"
        nameField.borderStyle = .roundedRect
        
        speciesField.placeholder = "Species"
        speciesField.borderStyle = .roundedRect
        
        breedField.placeholder = "Breed"
        breedField.borderStyle = .roundedRect
        
        ageField.placeholder = "Age"
        ageField.borderStyle = .roundedRect
        ageField.keyboardType = .numberPad
        
        colorField.placeholder = "Color"
        colorField.borderStyle = .roundedRect
        
        genderField.placeholder = "Gender"
        genderField.borderStyle = .roundedRect
        
        // Добавление UI элементов
        contentView.addSubview(titleLabel)
        contentView.addSubview(closeButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }
        
        // Добавление полей формы
        let formFields = [
            createFormRow(label: "Name *", field: nameField),
            createFormRow(label: "Species *", field: speciesField),
            createFormRow(label: "Breed", field: breedField),
            createFormRow(label: "Age", field: ageField),
            createFormRow(label: "Color", field: colorField),
            createFormRow(label: "Gender", field: genderField)
        ]
        
        var lastView: UIView = titleLabel
        
        for (index, fieldView) in formFields.enumerated() {
            contentView.addSubview(fieldView)
            
            fieldView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(16)
                make.leading.trailing.equalToSuperview().inset(20)
            }
            
            lastView = fieldView
        }
        
        // Distinctive features
        contentView.addSubview(distinctiveFeaturesTextView)
        distinctiveFeaturesTextView.addSubview(distinctiveFeaturesPlaceholder)
        
        distinctiveFeaturesTextView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        distinctiveFeaturesPlaceholder.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(8)
        }
        
        // Status
        contentView.addSubview(statusLabel)
        contentView.addSubview(statusSegmentedControl)
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(distinctiveFeaturesTextView.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(20)
        }
        
        statusSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Update button
        contentView.addSubview(updateButton)
        updateButton.addSubview(activityIndicator)
        
        updateButton.snp.makeConstraints { make in
            make.top.equalTo(statusSegmentedControl.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        // Delete button
        contentView.addSubview(deleteButton)
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(updateButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(32)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        distinctiveFeaturesTextView.delegate = self
    }
    
    private func setupPresenter() {
        presenter.view = self
    }
    
    private func fillFormWithPetData() {
        nameField.text = pet.name
        speciesField.text = pet.species
        breedField.text = pet.breed
        ageField.text = pet.age
        colorField.text = pet.color
        genderField.text = pet.gender
        
        if !pet.description.isEmpty {
            distinctiveFeaturesTextView.text = pet.description
            distinctiveFeaturesPlaceholder.isHidden = true
        }
        
        // Set status
        switch pet.status.lowercased() {
        case "home":
            statusSegmentedControl.selectedSegmentIndex = 0
        case "lost":
            statusSegmentedControl.selectedSegmentIndex = 1
        default:
            statusSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func updateButtonTapped() {
        guard let name = nameField.text, !name.isEmpty,
              let species = speciesField.text, !species.isEmpty else {
            showAlert(title: "Missing Information", message: "Please provide a name and species.")
            return
        }
        
        // Получение остальных полей
        let breed = breedField.text?.isEmpty == true ? nil : breedField.text
        let ageText = ageField.text
        let age = (ageText != nil && !ageText!.isEmpty) ? Int(ageText!) : nil
        let color = colorField.text?.isEmpty == true ? nil : colorField.text
        let gender = genderField.text?.isEmpty == true ? nil : genderField.text
        let distinctiveFeatures = distinctiveFeaturesTextView.text.isEmpty ? nil : distinctiveFeaturesTextView.text
        
        let status: String
        switch statusSegmentedControl.selectedSegmentIndex {
        case 0:
            status = "home"
        case 1:
            status = "lost"
        case 2:
            status = "found"
        default:
            status = "home"
        }
        
        // Показать состояние загрузки
        updateButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        updateButton.isEnabled = false
        
        // Вызов презентера для обновления питомца
        presenter.updatePet(
            id: pet.id,
            name: name,
            species: species,
            breed: breed,
            age: age,
            color: color,
            gender: gender,
            distinctiveFeatures: distinctiveFeatures,
            status: status
        )
    }
    
    @objc private func deleteButtonTapped() {
        // Show confirmation alert before deleting
        let alertController = UIAlertController(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete \(pet.name)? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Show loading state
            self.deleteButton.setTitle("", for: .normal)
            self.activityIndicator.startAnimating()
            self.deleteButton.isEnabled = false
            self.updateButton.isEnabled = false
            
            // Call presenter to delete pet
            self.presenter.deletePet(petId: self.pet.id)
        })
        
        present(alertController, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func createFormRow(label: String, field: UITextField) -> UIView {
        let containerView = UIView()
        
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 16, weight: .medium)
        
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

// MARK: - EditPetViewDelegate

extension EditPetViewController: EditPetViewDelegate {
    func petUpdated(pet: MyPetModel) {
        delegate?.petUpdated(pet: pet)
        dismiss(animated: true)
    }
    
    func petDeleted(petId: Int) {
        delegate?.petDeleted(petId: petId)
        dismiss(animated: true)
    }
    
    func showError(message: String) {
        updateButton.setTitle("Update Pet", for: .normal)
        deleteButton.isEnabled = true
        updateButton.isEnabled = true
        activityIndicator.stopAnimating()
        
        showAlert(title: "Error", message: message)
    }
}
