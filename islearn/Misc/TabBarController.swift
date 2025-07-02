import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
                // Wait for session restore
                try await SupabaseManager.shared.restoreSession()

                // Now check the session
                do {
                    let session = try await SupabaseManager.shared.auth.session
                    
                    if session.user != nil {
                        print("✅ User session is active: \(session.user.id)")
                        // Proceed to main screen (do nothing)
                    } else {
                        print("❌ No valid session found after restore.")
                        self.presentLoginScreen()
                    }
                } catch {
                    print("❌ Error fetching session:", error.localizedDescription)
                    self.presentLoginScreen()
                }
            }
    }

    // Function to present login screen
    func presentLoginScreen() {
        let loginVC = LoginViewController()
        self.present(loginVC, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let currentUser = ProfileDataModel.sharedInstance.getCurrentUserProfile() else {
            print("No current user profile found.")
            return
        }
        
        if currentUser.showOnboarding {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController {
                onboardingVC.modalPresentationStyle = .overFullScreen
                present(onboardingVC, animated: true, completion: nil)
            } else {}
        }
    }
    
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) {
        ProfileDataModel.sharedInstance.setOnboardingCompleted()
    }
}

