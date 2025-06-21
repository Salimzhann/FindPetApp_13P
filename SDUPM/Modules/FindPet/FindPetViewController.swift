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
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
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
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemGreen
        
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
        
        // Спрашиваем пользователя, хочет ли он добавить найденного питомца в список найденных
        let alert = UIAlertController(
            title: "Add Found Pet",
            message: "Would you like to add this pet to the list of found pets?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Запрашиваем разрешение на использование местоположения
            self.requestLocationPermissionIfNeeded { hasPermission in
                if hasPermission {
                    // Показываем индикатор загрузки
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = false
                        self.activityIndicator.startAnimating()
                    }
                    
                    // Получаем текущее местоположение
                    self.getLocation { coordinates in
                        DispatchQueue.main.async {
                            self.view.isUserInteractionEnabled = true
                            self.activityIndicator.stopAnimating()
                            
                            // Выполняем поиск с сохранением (save: true)
                            self.presenter.searchPet(
                                photo: self.selectedImages.first!,
                                species: species.lowercased(),
                                color: color,
                                gender: gender,
                                breed: breed,
                                coordX: coordinates?.latitude,
                                coordY: coordinates?.longitude,
                                save: true
                            )
                        }
                    }
                } else {
                    // Если нет разрешения на местоположение, всё равно выполняем поиск
                    self.presenter.searchPet(
                        photo: self.selectedImages.first!,
                        species: species.lowercased(),
                        color: color,
                        gender: gender,
                        breed: breed,
                        coordX: nil,
                        coordY: nil,
                        save: true
                    )
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            
            // Выполняем поиск без сохранения (save: false)
            self.presenter.searchPet(
                photo: self.selectedImages.first!,
                species: species.lowercased(),
                color: color,
                gender: gender,
                breed: breed,
                coordX: nil,
                coordY: nil,
                save: false
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
        selectedImages = []
        speciesTextField.text = ""
        colorTextField.text = ""
        genderTextField.text = ""
        breedTextField.text = ""
        photoCollectionView.reloadData()
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            self.showErrorAlert(message: message)
        }
    }
    
    func showSuccess(message: String) {
        // Убираем алерт успеха и вместо этого перенаправляем на страницу результатов
        // Обработка ответа уже происходит в presenter.searchPet
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
