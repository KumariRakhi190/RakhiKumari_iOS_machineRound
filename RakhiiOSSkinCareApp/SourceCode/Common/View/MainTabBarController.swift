//
//  MainTabBarController.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 27/09/26.
//

import UIKit

/// Two tabs: Home (care types -> categories -> tips) and Favourites.
class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    private func setupTabs() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let homeNavigationController = storyboard.instantiateInitialViewController() as? UINavigationController else {
            return
        }
        homeNavigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))

        // Loaded from the storyboard so its @IBOutlets are connected.
        guard let favouritesViewController = storyboard.instantiateViewController(withIdentifier: "FavouritesViewController") as? FavouritesViewController else {
            return
        }
        let favouritesNavigationController = UINavigationController(rootViewController: favouritesViewController)
        favouritesNavigationController.setNavigationBarHidden(true, animated: false)
        favouritesNavigationController.tabBarItem = UITabBarItem(title: "Favourites", image: UIImage(systemName: "heart"), selectedImage: UIImage(systemName: "heart.fill"))

        viewControllers = [homeNavigationController, favouritesNavigationController]
    }

    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .systemPink
    }
}
