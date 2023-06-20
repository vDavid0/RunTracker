//
//  ViewController.swift
//  RunTracker
//
//  Created by Dávid Váradi on 2022. 11. 30..
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var startTrainingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
        
        tabBarController?.tabBar.items?.first?.title = "New training"
        tabBarController?.tabBar.items?.last?.title = "History"
        
        tabBarController?.tabBar.tintColor = UIColor(red: 0.9, green: 0.4, blue: 0, alpha: 1)
        tabBarController?.tabBar.unselectedItemTintColor = .lightGray
        
        tabBarController?.tabBar.backgroundColor = .darkGray.withAlphaComponent(0.6)
        
        backgroundImageView.alpha = 0.9
    }
    
    @IBAction func startTrainingButtonPressed(_ sender: Any) {

    }
}


