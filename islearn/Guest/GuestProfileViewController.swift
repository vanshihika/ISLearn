//
//  GuestProfileViewController.swift
//  islearn
//
//  Created by Vanshika Choudhary on 4/6/25.
//


import UIKit

class GuestProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        // Message Label
        let messageLabel = UILabel()
        messageLabel.text = "You're currently browsing as a guest.\nSign up to unlock the full experience."
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 18)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        // Sign Up Button
        let signupButton = UIButton(type: .system)
        signupButton.setTitle("Go To Sign Up", for: .normal)
        signupButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        signupButton.backgroundColor = .accent
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.layer.cornerRadius = 10
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)

        // Add to view
        view.addSubview(messageLabel)
        view.addSubview(signupButton)

        // Constraints
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            signupButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signupButton.widthAnchor.constraint(equalToConstant: 200),
            signupButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func signupButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginSignupVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            loginSignupVC.modalPresentationStyle = .fullScreen
            present(loginSignupVC, animated: true, completion: nil)
        } else {
            print("Could not instantiate LoginViewController")
        }
    }

}
