import UIKit
import Supabase

class LoginViewController: UIViewController {
    
    private let supabase = SupabaseManager.shared
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Logo Stencil"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        let attributedText = NSMutableAttributedString(string: "Welcome To ")
        let iSLearnText = NSAttributedString(string: "iSLearn", attributes: [.foregroundColor: UIColor.accent])
        attributedText.append(iSLearnText)
        label.attributedText = attributedText
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let authSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Log In", "Sign Up"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .accent
        segmentedControl.backgroundColor = UIColor.systemGray5
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        return segmentedControl
    }()
    
    private func createTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
        textField.leftViewMode = .always
        textField.isSecureTextEntry = isSecure
        return textField
    }
    
    private lazy var emailTextField = createTextField(placeholder: "Enter Email")
    private lazy var passwordTextField = createTextField(placeholder: "Enter Password", isSecure: true)
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = createTextField(placeholder: "Confirm Password", isSecure: true)
        textField.isHidden = true
        return textField
    }()
    
    private let authButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .accent
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.title = "Log In"
        config.buttonSize = .large
        return UIButton(configuration: config)
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "or"
        label.textColor = .lightGray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    
    private let guestButton: UIButton = {
        var config = UIButton.Configuration.gray()
        config.baseBackgroundColor = UIColor(white: 1.0, alpha: 0.2)
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.buttonSize = .large
        
        // Set the title
        config.title = "Continue as Guest"
        
        // Set the image with the SF symbol `person.fill`
        let image = UIImage(systemName: "person.fill")
        config.image = image
        config.imagePadding = 8 // Adjust padding between the symbol and text
        config.imagePlacement = .leading // Place the image to the left of the title
        
        return UIButton(configuration: config)
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLayout()
        
        authButton.addTarget(self, action: #selector(authenticateUser), for: .touchUpInside)
        authSegmentedControl.addTarget(self, action: #selector(toggleAuthMode), for: .valueChanged)
        guestButton.addTarget(self, action: #selector(continueAsGuest), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    
    private func setupLayout() {
        [logoImageView, titleLabel, authSegmentedControl, emailTextField, passwordTextField, confirmPasswordTextField, authButton, orLabel, guestButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            authSegmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            authSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            authSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            authSegmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            emailTextField.topAnchor.constraint(equalTo: authSegmentedControl.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 24), // Increased spacing here
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24), // Increased spacing here
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            authButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 50), // Increased spacing here
            authButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            authButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            authButton.heightAnchor.constraint(equalToConstant: 48),
            
            orLabel.topAnchor.constraint(equalTo: authButton.bottomAnchor, constant: 20), // Increased spacing here
            orLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            guestButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 20), // Increased spacing here
            guestButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            guestButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            guestButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    
    
    @objc private func authenticateUser() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Email and password cannot be empty.")
            return
        }
        
        guard isValidEmail(email) else {
                showAlert(message: "Please enter a valid email address.")
                return
            }

        let isSignUp = authSegmentedControl.selectedSegmentIndex == 1

        if isSignUp {
            guard let confirmPassword = confirmPasswordTextField.text, confirmPassword == password else {
                showAlert(message: "Passwords do not match.")
                return
            }

            Task {
                do {
                    let session = try await supabase.auth.signUp(email: email, password: password)
                    print("✅ Signed up:", session)

                    let user = session.user
                    await setupProfileAndNavigate(for: user, isSignUp: true)
                    if let userId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id {
                        await BadgesDataModel.sharedInstance.checkAndUnlockBadges(for: userId)
                        await AchievementDataModel.sharedInstance.syncFromSupabase()
                        await AchievementDataModel.sharedInstance.checkAndUnlockAchievements(for: userId)
                    }
                    
                } catch {
                    showAlert(message: "Sign up failed: \(error.localizedDescription)")
                }
            }
        } else {
            Task {
                do {
                    let session = try await supabase.auth.signIn(email: email, password: password)
                    let user = session.user
                    SupabaseManager.shared.saveSession(session)
                    await setupProfileAndNavigate(for: user, isSignUp: false)
                } catch {
                    showAlert(message: "Login failed: \(error.localizedDescription)")
                }
            }
        }
    }
    

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "(?:[A-Z0-9a-z._%+-]+)@(?:[A-Za-z0-9-]+\\.)+[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }

    
    private func setupProfileAndNavigate(for user: User, isSignUp: Bool) async {
        do {
            let profile: Profile

            if isSignUp {
                profile = try await ProfileDataModel.sharedInstance.createUserProfile(for: user)
            } else {
//                profile = try await ProfileDataModel.sharedInstance.fetchUserProfile(user: user)
                do {
                        profile = try await ProfileDataModel.sharedInstance.fetchUserProfile(user: user)
                    } catch {
                        
                        profile = try await ProfileDataModel.sharedInstance.createUserProfile(for: user)
                    }
            }

            DispatchQueue.main.async {
                if isSignUp {
                    self.presentOnboardingScreen()
                } else {
                    self.presentHomeScreen()
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.showAlert(message: "Failed to set up profile: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func toggleAuthMode() {
        let isSignUp = authSegmentedControl.selectedSegmentIndex == 1
        confirmPasswordTextField.isHidden = !isSignUp
        authButton.configuration?.title = isSignUp ? "Sign Up" : "Log In"
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func presentHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else {
            print("Could not instantiate TabBarController")
            return
        }
        tabBarVC.modalPresentationStyle = .fullScreen
        self.present(tabBarVC, animated: true)
    }

    @objc private func continueAsGuest() {
        print("👤 Continuing as Guest")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let guestTabVC = storyboard.instantiateViewController(withIdentifier: "GuestTabBarViewController") as? UITabBarController {
            guestTabVC.modalPresentationStyle = .fullScreen
            self.present(guestTabVC, animated: true)
        } else {
            print("Could not load GuestTabViewController")
        }
    }


    private func presentOnboardingScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController {
            onboardingVC.modalPresentationStyle = .fullScreen
            self.present(onboardingVC, animated: true, completion: nil)
        } else {
            print("Could not load OnboardingViewController")
        }
    }

    private func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

