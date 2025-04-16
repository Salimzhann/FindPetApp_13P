import UIKit

class MainView: UIViewController {
    
    private let presenter = MainPresenter()
    
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
    
    private var petsArray: [LostPet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        presenter.view = self
        fetchData()
    }
    
    func setupUI() {
        navigationItem.title = "Lost Pets"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    func fetchData() {
        collectionView.reloadData()
        presenter.receiveData { data in
            self.petsArray = data
            self.collectionView.reloadData()
        }
    }
}


extension MainView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        petsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LosePetsCell.identifier, for: indexPath) as! LosePetsCell
        cell.item = petsArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let cellWidth = collectionView.frame.width
            return CGSize(width: cellWidth, height: 90)
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didTapDetail(id: petsArray[indexPath.item].id)
    }
}
