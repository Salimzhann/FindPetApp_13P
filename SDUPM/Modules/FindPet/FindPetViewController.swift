// SDUPM/Modules/FindPet/FindPetViewController.swift

import UIKit
import SnapKit
import PhotosUI
import CoreLocation
import ObjectiveC

protocol IFindPetView: AnyObject {
    func showLoading()
    func hideLoading()
    func navigateToSearchResults(response: PetSearchResponse)
    func showError(message: String)
    func showSuccess(message: String)
}

class SearchPhotoCell: UICollectionViewCell {
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

class FindPetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IFindPetView, CLLocationManagerDelegate {
    
    // Changed from private to fileprivate for access from extensions
    fileprivate var selectedImages: [UIImage] = []
    private let presenter = FindPetSearchPresenter()
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
    
    // Store completion handlers
    private var locationPermissionCompletion: ((Bool) -> Void)?
    private var locationCompletionHandler: ((CLLocationCoordinate2D?) -> Void)?
    
    // MARK: - UI Components
    
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
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Find a Pet"
        
        setupViews()
        setupActions()
        setupCollectionView()
        configurePresenter()
        hideKeyboardWhenTappedAround()
        setupLocationManager()
    }
    
    // MARK: - Setup Methods
    
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
            make.top.equalTo(uploadPhotoButton)
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
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    private func setupCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(SearchPhotoCell.self, forCellWithReuseIdentifier: "SearchPhotoCell")
    }
    
    // MARK: - Location Methods
    
    private func requestLocationPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus {
        case .notDetermined:
            // Store the completion handler
            locationPermissionCompletion = completion
            
            // Set self as delegate to receive authorization changes
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            completion(false)
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    // CLLocationManagerDelegate method for handling authorization changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationPermissionCompletion?(true)
        case .denied, .restricted:
            locationPermissionCompletion?(false)
        case .notDetermined:
            // Still waiting for user decision
            break
        @unknown default:
            locationPermissionCompletion?(false)
        }
        
        // Clear the completion handler after it's called
        locationPermissionCompletion = nil
    }
    
    private func getLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        // Store the completion handler
        locationCompletionHandler = completion
        
        // Clear any previous location
        currentLocation = nil
        
        // Set timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) { [weak self] in
            if self?.currentLocation == nil {
                self?.locationCompletionHandler?(nil)
                self?.locationCompletionHandler = nil
                self?.locationManager.stopUpdatingLocation()
            }
        }
        
        // Start location updates
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
            
            // Call the completion handler with the location
            locationCompletionHandler?(currentLocation)
            locationCompletionHandler = nil
            
            // Stop updates
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        
        // Call the completion handler with nil
        locationCompletionHandler?(nil)
        locationCompletionHandler = nil
        
        // Stop updates
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Actions
    
    @objc private func uploadPhotoTapped() {
        if #available(iOS 14, *) {
            // Use PHPicker for iOS 14 and up
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .images
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            // Fallback to UIImagePicker for older iOS
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true)
        }
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
        
        // First, ask about search purpose
        let actionSheet = UIAlertController(
            title: "Search Purpose",
            message: "What would you like to do?",
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(UIAlertAction(title: "Find My Pet", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.showLocationConfirmationAlert(
                photo: self.selectedImages.first!,
                species: species,
                color: color,
                gender: gender,
                breed: breed,
                isFindingOwner: false
            )
        })
        
        actionSheet.addAction(UIAlertAction(title: "Find Pet Owner", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.showLocationConfirmationAlert(
                photo: self.selectedImages.first!,
                species: species,
                color: color,
                gender: gender,
                breed: breed,
                isFindingOwner: true
            )
        })
        
        // Add new option to report a found pet
        actionSheet.addAction(UIAlertAction(title: "Report Found Pet", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Ask for location to add found pet
            self.askLocationForFoundPet(
                photo: self.selectedImages.first!,
                species: species,
                color: color,
                gender: gender,
                breed: breed
            )
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    private func askLocationForFoundPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?) {
        let alert = UIAlertController(
            title: "Add Pet to Found List",
            message: "We need your current location to help owners find where their pet was last seen. Do you want to share your location?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Yes, Share Location", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Request location permission
            self.requestLocationPermissionIfNeeded { hasPermission in
                if hasPermission {
                    // Show loading during location fetch
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = false
                        self.activityIndicator.startAnimating()
                    }
                    
                    // Get current location
                    self.getLocation { coordinates in
                        DispatchQueue.main.async {
                            self.view.isUserInteractionEnabled = true
                            self.activityIndicator.stopAnimating()
                            
                            // Report found pet with or without location
                            self.presenter.reportFoundPet(
                                photo: photo,
                                species: species.lowercased(),
                                color: color,
                                gender: gender,
                                breed: breed,
                                location: coordinates
                            )
                        }
                    }
                } else {
                    // No permission - show alert
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Location permission denied. The pet will be added without location information.")
                        
                        // Report found pet without location
                        self.presenter.reportFoundPet(
                            photo: photo,
                            species: species.lowercased(),
                            color: color,
                            gender: gender,
                            breed: breed,
                            location: nil
                        )
                    }
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "No, Continue Without Location", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            
            // Report found pet without location
            self.presenter.reportFoundPet(
                photo: photo,
                species: species.lowercased(),
                color: color,
                gender: gender,
                breed: breed,
                location: nil
            )
        })
        
        present(alert, animated: true)
    }
    
    private func showLocationConfirmationAlert(photo: UIImage, species: String, color: String, gender: String?, breed: String?, isFindingOwner: Bool = true) {
        let alert = UIAlertController(
            title: "Location Needed",
            message: isFindingOwner
                ? "To find the pet owner, we need your current location. Do you want to share your location?"
                : "Sharing your location will help us find your pet. Do you want to share your location?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Yes, Share Location", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Request location permission if needed
            self.requestLocationPermissionIfNeeded { hasPermission in
                if hasPermission {
                    // Show loading indicator during location fetch
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = false
                        self.activityIndicator.startAnimating()
                    }
                    
                    // Get current location
                    self.getLocation { coordinates in
                        DispatchQueue.main.async {
                            self.view.isUserInteractionEnabled = true
                            self.activityIndicator.stopAnimating()
                            
                            if let coordinates = coordinates {
                                // Proceed with search using location
                                self.presenter.searchPet(
                                    photo: photo,
                                    species: species.lowercased(),
                                    color: color,
                                    gender: gender,
                                    breed: breed,
                                    isFindingOwner: isFindingOwner
                                )
                            } else {
                                // Show error - couldn't get location
                                self.showErrorAlert(message: "Could not determine your location. Please try again or search without location.")
                            }
                        }
                    }
                } else {
                    // No permission - show alert
                    DispatchQueue.main.async {
                        self.showNoLocationPermissionAlert(
                            photo: photo,
                            species: species,
                            color: color,
                            gender: gender,
                            breed: breed,
                            isFindingOwner: isFindingOwner
                        )
                    }
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "No, Search Without Location", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            
            // Proceed without location
            self.presenter.searchPet(
                photo: photo,
                species: species.lowercased(),
                color: color,
                gender: gender,
                breed: breed,
                isFindingOwner: isFindingOwner
            )
        })
        
        present(alert, animated: true)
    }
    
    private func showNoLocationPermissionAlert(photo: UIImage, species: String, color: String, gender: String?, breed: String?, isFindingOwner: Bool = true) {
        let alert = UIAlertController(
            title: "Location Access Denied",
            message: "You have denied access to your location. You can change this in your device settings or search without location.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Search Without Location", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            
            // Proceed without location
            self.presenter.searchPet(
                photo: photo,
                species: species.lowercased(),
                color: color,
                gender: gender,
                breed: breed,
                isFindingOwner: isFindingOwner
            )
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - IFindPetView Implementation
    
    func showLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.searchButton.isEnabled = false
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.searchButton.isEnabled = true
        }
    }
    
    func navigateToSearchResults(response: PetSearchResponse) {
        DispatchQueue.main.async {
            let resultsVC = FoundPetViewController(searchResponse: response)
            self.navigationController?.pushViewController(resultsVC, animated: true)
        }
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            self.showErrorAlert(message: message)
        }
    }
    
    func showSuccess(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
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
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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

// MARK: - UICollectionView Delegate & DataSource
extension FindPetViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchPhotoCell", for: indexPath) as! SearchPhotoCell
        cell.configure(with: selectedImages[indexPath.item])
        return cell
    }
}

// MARK: - PHPickerViewControllerDelegate
@available(iOS 14, *)
extension FindPetViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.selectedImages = [image]
                    self?.photoCollectionView.reloadData()
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self?.showError(message: "Failed to load image: \(error.localizedDescription)")
                }
            }
        }
    }
}
