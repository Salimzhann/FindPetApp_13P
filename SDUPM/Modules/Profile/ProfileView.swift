//
//  ProfileView.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 20.10.2024.
//

//
//  ProfileView.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 20.10.2024.
//

import UIKit

class ProfileView: UIViewController {
    
    private let presenter = ProfilePresenter()
    
    private lazy var profileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: "default")
        image.clipsToBounds = true
        image.layer.cornerRadius = 75
        return image
    }()
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        return label
    }()
    
    private lazy var phoneNumber: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выбрать фотографию", for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.label, for: .normal)
        
        let cameraIcon = UIImage(systemName: "arrow.triangle.2.circlepath.camera")
        button.setImage(cameraIcon, for: .normal)
        
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        button.addTarget(self, action: #selector(editProfileImage), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var aboutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("О приложений", for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.label, for: .normal)
        
        let infoIcon = UIImage(systemName: "info.square")
        button.setImage(infoIcon, for: .normal)
        
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        button.addTarget(self, action: #selector(showAboutApplication), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var rateAppButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Оценить приложение", for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.label, for: .normal)
        
        let rateIcon = UIImage(systemName: "star")
        button.setImage(rateIcon, for: .normal)
        
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        button.addTarget(self, action: #selector(rateApp), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var shareAppButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Рассказать другу", for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.label, for: .normal)
        
        let shareIcon = UIImage(systemName: "square.and.arrow.up")
        button.setImage(shareIcon, for: .normal)
        
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        button.addTarget(self, action: #selector(shareApp), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выйти", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return button
    }()
    
    private lazy var notificationsSwitch: UISwitch = {
        let notificationSwitch = UISwitch()
        notificationSwitch.isOn = true
        notificationSwitch.addTarget(self, action: #selector(toggleNotifications), for: .valueChanged)
        return notificationSwitch
    }()
    
    private lazy var notificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Получать уведомление"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var notificationsView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 16
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.view = self
        fetchData()
    }
    
    private func setupUI() {
        [profileImage, fullNameLabel, phoneNumber, editProfileButton, aboutButton, rateAppButton, shareAppButton, logoutButton, loadingIndicator, notificationsView, notificationsLabel, notificationsSwitch].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        })
        
        NSLayoutConstraint.activate([
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            // Profile image
            profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImage.heightAnchor.constraint(equalToConstant: 150),
            profileImage.widthAnchor.constraint(equalToConstant: 150),
            
            // Full name
            fullNameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 10),
            fullNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Phone number
            phoneNumber.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 5),
            phoneNumber.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Edit Profile Image button
            editProfileButton.topAnchor.constraint(equalTo: phoneNumber.bottomAnchor, constant: 20),
            editProfileButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            editProfileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            editProfileButton.heightAnchor.constraint(equalToConstant: 40),
            
            // About button
            aboutButton.topAnchor.constraint(equalTo: editProfileButton.bottomAnchor, constant: 5),
            aboutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            aboutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            aboutButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Rate App button
            rateAppButton.topAnchor.constraint(equalTo: aboutButton.bottomAnchor, constant: 5),
            rateAppButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            rateAppButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rateAppButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Share App button
            shareAppButton.topAnchor.constraint(equalTo: rateAppButton.bottomAnchor, constant: 5),
            shareAppButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            shareAppButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            shareAppButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Notifications view
            notificationsView.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -20),
            notificationsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            notificationsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            notificationsView.heightAnchor.constraint(equalToConstant: 50),
            
            // Notifications label
            notificationsLabel.centerYAnchor.constraint(equalTo: notificationsView.centerYAnchor),
            notificationsLabel.leadingAnchor.constraint(equalTo: notificationsView.leadingAnchor, constant: 20),
            
            // Notifications switch
            notificationsSwitch.centerYAnchor.constraint(equalTo: notificationsView.centerYAnchor),
            notificationsSwitch.trailingAnchor.constraint(equalTo: notificationsView.trailingAnchor, constant: -20),
            
            // Logout button
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func fetchData() {
        presenter.fetchProfile()
    }
    
    func configure(model: UserProfile) {
        fullNameLabel.text = "\(model.firstName) \(model.lastName)"
        phoneNumber.text = model.phone
    }

    @objc private func editProfileImage() {
        // Open image picker to change the profile image
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    @objc private func logout() {
        UserDefaults.standard.removeObject(forKey: LoginView.isActive)
        UserDefaults.standard.removeObject(forKey: LoginInViewModel.tokenIdentifier)
        
        if let window = UIApplication.shared.keyWindow {
                // Создаем новый корневой контроллер с экраном SignInView
                let signInViewController = SignInView()
                let navigationController = UINavigationController(rootViewController: signInViewController)
                
                // Меняем корневой контроллер
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
    }
    func showLoading() {
        DispatchQueue.main.async {
            [self.profileImage, self.fullNameLabel, self.phoneNumber, self.editProfileButton, self.aboutButton, self.rateAppButton, self.shareAppButton, self.logoutButton, self.loadingIndicator, self.notificationsView, self.notificationsLabel, self.notificationsSwitch].forEach { view in
                view.isHidden = true
            }
            
            self.loadingIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
        }
    }

    func hideLoading() {
        DispatchQueue.main.async {
            
            [self.profileImage, self.fullNameLabel, self.phoneNumber, self.editProfileButton, self.aboutButton, self.rateAppButton, self.shareAppButton, self.logoutButton, self.loadingIndicator, self.notificationsView, self.notificationsLabel, self.notificationsSwitch].forEach { view in
                view.isHidden = false
            }
            self.loadingIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    @objc private func toggleNotifications() {
        if notificationsSwitch.isOn {
            print("Notifications Enabled")
        } else {
            print("Notifications Disabled")
        }
    }

    @objc private func showAboutApplication() {
        // Show about application details
        let alertController = UIAlertController(title: "About Application", message: "This is the about section of the application.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func rateApp() {
        // Add your rate app logic here
        print("Rate app tapped")
    }
    
    @objc private func shareApp() {
        // Add your share app logic here
        print("Share app tapped")
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ProfileView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            profileImage.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
