import UIKit

class OnboardingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        ProfileDataModel.sharedInstance.setOnboardingCompleted()

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            window.rootViewController = tabBarVC
            window.makeKeyAndVisible()
        }
    }
}

