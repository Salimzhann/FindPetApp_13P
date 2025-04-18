import UIKit
import SnapKit
import MapKit

class MainView: UIViewController {
    
    private let presenter = MainPresenter()
    
    enum DisplayMode {
        case list
        case map
    }
    
    private var displayMode: DisplayMode = .list {
        didSet {
            updateDisplayMode()
        }
    }
    
    private let displayModeSegmentedControl: UISegmentedControl = {
        let items = ["Список", "Карта"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.tintColor = .systemGreen
        return control
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.register(LosePetsCell.self, forCellWithReuseIdentifier: LosePetsCell.identifier)
        return cv
    }()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.isHidden = true
        return map
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .systemGreen
        return indicator
    }()
    
    private var petsArray: [LostPet] = []
    
    // Для демонстрации карты - примерные координаты в Алматы
    private let defaultCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 43.238949, longitude: 76.889709),
        CLLocationCoordinate2D(latitude: 43.222015, longitude: 76.851258),
        CLLocationCoordinate2D(latitude: 43.258206, longitude: 76.950542)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        mapView.delegate = self
        
        presenter.view = self
        fetchData()
    }
    
    func setupUI() {
        navigationItem.title = "Потерянные питомцы"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .systemBackground
        
        // Добавляем переключатель режимов отображения
        view.addSubview(displayModeSegmentedControl)
        displayModeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
        
        displayModeSegmentedControl.addTarget(self, action: #selector(displayModeChanged), for: .valueChanged)
        
        // Добавляем коллекцию
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(displayModeSegmentedControl.snp.bottom).offset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        // Добавляем карту
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(displayModeSegmentedControl.snp.bottom).offset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        // Добавляем индикатор загрузки
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @objc private func displayModeChanged() {
        displayMode = displayModeSegmentedControl.selectedSegmentIndex == 0 ? .list : .map
    }
    
    private func updateDisplayMode() {
        switch displayMode {
        case .list:
            collectionView.isHidden = false
            mapView.isHidden = true
        case .map:
            collectionView.isHidden = true
            mapView.isHidden = false
            updateMapAnnotations()
        }
    }
    
    private func updateMapAnnotations() {
        // Удаляем старые аннотации
        mapView.removeAnnotations(mapView.annotations)
        
        // Поскольку API не возвращает координаты, используем примерные координаты для демонстрации
        for (index, pet) in petsArray.enumerated() {
            let coordinate = defaultCoordinates[index % defaultCoordinates.count]
            let annotation = PetAnnotation(pet: pet, coordinate: coordinate)
            mapView.addAnnotation(annotation)
        }
        
        // Устанавливаем начальный регион карты для Казахстана
        if !defaultCoordinates.isEmpty {
            let coordinate = defaultCoordinates[0]
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            mapView.setRegion(region, animated: true)
        }
    }
    
    func fetchData() {
        showLoading()
        
        presenter.fetchLostPets { [weak self] pets in
            guard let self = self else { return }
            self.petsArray = pets
            self.collectionView.reloadData()
            
            if self.displayMode == .map {
                self.updateMapAnnotations()
            }
            
            self.hideLoading()
        }
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
        collectionView.isHidden = true
        mapView.isHidden = true
        displayModeSegmentedControl.isEnabled = false
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        displayModeSegmentedControl.isEnabled = true
        updateDisplayMode()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension MainView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return petsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LosePetsCell.identifier, for: indexPath) as! LosePetsCell
        cell.pet = petsArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width
        return CGSize(width: cellWidth, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Передаем ID как строку
        let id = petsArray[indexPath.item].id
        presenter.didTapDetail(id: id)
    }
}

// MARK: - MKMapViewDelegate
extension MainView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Пропускаем аннотацию пользователя
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        guard let petAnnotation = annotation as? PetAnnotation else { return nil }
        
        let identifier = "PetAnnotation"
        var annotationView: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            annotationView = dequeuedView
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            annotationView.calloutOffset = CGPoint(x: -5, y: 5)
            
            // Добавляем кнопку для показа деталей
            let button = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = button
        }
        
        // Устанавливаем цвет маркера в зависимости от вида животного
        let species = petAnnotation.pet.species.lowercased()
        if species == "dog" {
            annotationView.markerTintColor = .systemBlue
        } else if species == "cat" {
            annotationView.markerTintColor = .systemOrange
        } else {
            annotationView.markerTintColor = .systemGreen
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? PetAnnotation else { return }
        presenter.didTapDetail(id: annotation.pet.id)
    }
}
