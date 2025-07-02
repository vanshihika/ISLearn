//
//  SplashScreen.swift
//  islearn
//
//  Created by Vanshika Choudhary on 7/6/25.
//

import Foundation

import UIKit

class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let logo = UIImageView(image: UIImage(named: "LoaderLogo"))
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logo)
        
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logo.widthAnchor.constraint(equalToConstant: 240),
            logo.heightAnchor.constraint(equalToConstant: 240)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.goToMain()
        }
    }
    
    func goToMain() {
        let mainVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateInitialViewController()!
        mainVC.modalTransitionStyle = .crossDissolve
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true)
    }
}

