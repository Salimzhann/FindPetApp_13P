//
//  TabBarViewController.swift
//  SDUCanteenApp
//
//  Created by Manas Salimzhan on 14.09.2024.
//

import UIKit

class NavigationViewModel: UITabBarController {
    let vc1 = MainView()
    let vc2 = FindPetViewController()
    let vc3 = MyPetViewController()
    let vc4 = ProfileView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        [vc1, vc2, vc3, vc4].forEach({$0.navigationItem.largeTitleDisplayMode = .always})
        
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        let nav4 = UINavigationController(rootViewController: vc4)
        
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        nav2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "My Pets", image: UIImage(systemName: "pawprint.circle"), tag: 2)
        nav4.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
        
        [nav1, nav2, nav3, nav4].forEach({ $0.navigationBar.prefersLargeTitles = true })
        tabBar.tintColor = .systemGreen
        tabBar.barTintColor = .lightGray
        tabBar.scrollEdgeAppearance = .none
        setViewControllers([nav1, nav2, nav3, nav4], animated: true)
    }
}
