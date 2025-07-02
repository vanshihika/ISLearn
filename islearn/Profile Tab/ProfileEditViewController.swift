//import UIKit
//
//class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
//
//    @IBOutlet weak var pushNotification: UISwitch!
//    @IBOutlet weak var editProfileImage: UIImageView!
//    @IBOutlet weak var newNameTextField: UITextField!
//    
//    @IBOutlet weak var logOutButton: UIButton!
//    private let deleteAccountButton = UIButton(type: .system)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationItem.title = "Edit Profile"
//        setupUI()
//        loadUserProfile()
//        setupDeleteAccountButton()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        editProfileImage.layer.cornerRadius = editProfileImage.frame.size.width / 2.1
//        editProfileImage.clipsToBounds = true
//        editProfileImage.layer.borderWidth = 1.5
//        editProfileImage.layer.borderColor = UIColor.systemGray4.cgColor
//    }
//
//    private func setupUI() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tapGesture)
//        newNameTextField.delegate = self
//    }
//    
//    private func setupDeleteAccountButton() {
//        deleteAccountButton.setTitle("Delete Account", for: .normal)
//        deleteAccountButton.setTitleColor(.systemBlue, for: .normal)
//        deleteAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(deleteAccountButton)
//        
//        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonTapped(_:)), for: .touchUpInside)
//
//        NSLayoutConstraint.activate([
//            deleteAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            deleteAccountButton.bottomAnchor.constraint(equalTo: logOutButton.topAnchor, constant: -24)
//        ])
//    }
//
//
//    @objc private func dismissKeyboard() {
//        view.endEditing(true)
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//    private func loadUserProfile() {
//        guard let currentUser = ProfileDataModel.sharedInstance.getCurrentUserProfile() else { return }
//
//        if let imageBase64 = currentUser.image,
//           let imageData = Data(base64Encoded: imageBase64),
//           let image = UIImage(data: imageData) {
//            editProfileImage.image = image
//        } else {
//            editProfileImage.image = UIImage(systemName: "person.fill")
//        }
//
//        pushNotification.isOn = currentUser.notifications
//        newNameTextField.text = currentUser.name
//    }
//    
////    private func addAccountManagementButtons() {
////        let buttonHeight: CGFloat = 44
////        let spacing: CGFloat = 12
////        let buttonWidth = view.frame.width - 40
////        
////        let changePasswordButton = UIButton(type: .system)
////        changePasswordButton.setTitle("Change Password", for: .normal)
////        changePasswordButton.setTitleColor(.systemBlue, for: .normal)
////        changePasswordButton.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.2)
////        changePasswordButton.layer.cornerRadius = 8
////        changePasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
////        changePasswordButton.addTarget(self, action: #selector(changePasswordButtonTapped), for: .touchUpInside)
////
////        let logoutButton = UIButton(type: .system)
////        logoutButton.setTitle("Log Out", for: .normal)
////        logoutButton.setTitleColor(.systemRed, for: .normal)
////        logoutButton.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.2)
////        logoutButton.layer.cornerRadius = 8
////        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
////        logoutButton.addTarget(self, action: #selector(logOutButtonTapped), for: .touchUpInside)
////
////        // Stack view to organize buttons vertically
////        let stackView = UIStackView(arrangedSubviews: [changePasswordButton, logoutButton])
////        stackView.axis = .vertical
////        stackView.spacing = spacing
////        stackView.distribution = .fillEqually
////        stackView.translatesAutoresizingMaskIntoConstraints = false
////        view.addSubview(stackView)
////
////        // Constraints
////        NSLayoutConstraint.activate([
////            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
////            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
////            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
////            stackView.heightAnchor.constraint(equalToConstant: (buttonHeight * 2) + spacing)
////        ])
////    }
//    
////    @objc private func changePasswordButtonTapped() {
////        let alertController = UIAlertController(
////            title: "Change Password",
////            message: "This will redirect you to the password change flow.",
////            preferredStyle: .alert
////        )
////
////        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
////        alertController.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
////            // Navigate to your password change screen
////            self.performSegue(withIdentifier: "showChangePassword", sender: self)
////        })
////
////        present(alertController, animated: true)
////    }
////
////    @objc private func logOutButtonTapped() {
////        let alertController = UIAlertController(
////            title: "Log Out",
////            message: "Are you sure you want to log out?",
////            preferredStyle: .alert
////        )
////
////        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
////        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
////            Task {
////                do {
////                    try await SupabaseManager.shared.auth.signOut()
////                    
////                    // Clear any local profile data if necessary
//////                    ProfileDataModel.sharedInstance.clearCachedUser()
////
////                    // Navigate to login or welcome screen
////                    DispatchQueue.main.async {
////                        self.navigateToMainPage()
////                    }
////                } catch {
////                    DispatchQueue.main.async {
////                        self.showAlert(title: "Error", message: "Failed to log out. Please try again.")
////                    }
////                }
////            }
////        })
////
////        present(alertController, animated: true)
////    }
//
//    @IBAction func tapped(_ sender: UIButton) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//
//        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            alertController.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
//                imagePicker.sourceType = .camera
//                self.present(imagePicker, animated: true)
//            })
//        }
//
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
//                imagePicker.sourceType = .photoLibrary
//                self.present(imagePicker, animated: true)
//            })
//        }
//        
//        if let popoverController = alertController.popoverPresentationController {
//            popoverController.sourceView = sender
//            popoverController.sourceRect = sender.bounds
//        }
//
//        present(alertController, animated: true)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        if let selectedImage = info[.originalImage] as? UIImage {
//            editProfileImage.image = selectedImage
//        }
//        dismiss(animated: true)
//    }
//
//    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
//        guard let updatedName = newNameTextField.text,
//              !updatedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            showAlert(title: "Missing Name", message: "Please enter a valid name.")
//            return
//        }
//
//        guard let updatedImage = editProfileImage.image,
//              let imageData = updatedImage.jpegData(compressionQuality: 0.8) else {
//            showAlert(title: "Missing Image", message: "Please select a profile image.")
//            return
//        }
//
//        let imageBase64 = imageData.base64EncodedString()
//        
//        ProfileDataModel.sharedInstance.updateProfileDataFromBase64(
//            updatedName,
//            imageBase64,
//            pushNotification.isOn
//        )
//
//        navigationController?.popViewController(animated: true)
//    }
//    
//    @IBAction func cancelButtonTapped(_ sender: Any) {
//        performSegue(withIdentifier: "unwindToCancelProfileViewControllerWithSegue", sender: self)
//    }
//    
//    @IBAction func deleteAccountButtonTapped(_ sender: UIButton) {
//        guard let currentUser = ProfileDataModel.sharedInstance.getCurrentUserProfile() else { return }
//
//        let alertController = UIAlertController(
//            title: "Delete Account",
//            message: "Are you sure you want to permanently delete your account? This cannot be undone.",
//            preferredStyle: .alert
//        )
//
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
//            Task {
//                let userId = currentUser.id
//
//                do {
//                    try await SupabaseManager.shared.client
//                        .from("user_test_progress")
//                        .delete()
//                        .eq("user_id", value: userId.uuidString)
//                        .execute()
//                } catch {
//                    DispatchQueue.main.async {
//                        self.showAlert(title: "Error", message: "Failed to delete progress data: \(error.localizedDescription)")
//                    }
//                    return
//                }
//
//                // 2. Sign out the user to clear any active sessions before deletion
//                do {
//                    try await SupabaseManager.shared.auth.signOut()
//                } catch {
//                    DispatchQueue.main.async {
//                        self.showAlert(title: "Error", message: "Failed to sign out: \(error.localizedDescription)")
//                    }
//                    return
//                }
//
//                // 3. Delete from 'profiles' table in Supabase
//                do {
//                    try await SupabaseManager.shared.client
//                        .from("profiles")
//                        .delete()
//                        .eq("id", value: userId)
//                        .execute()
//                } catch {
//                    DispatchQueue.main.async {
//                        self.showAlert(title: "Error", message: "Failed to delete profile: \(error.localizedDescription)")
//                    }
//                    return
//                }
//
//                // 4. Delete related data from other tables (e.g., achievements, badges)
//                do {
//                    await AchievementDataModel.sharedInstance.deleteData(for: userId)
//                    BadgesDataModel.sharedInstance.deleteData(for: userId)
//                    JourneyDataModel.shared.deleteData(for: userId)
//                    BookMarkedWords.sharedInstance.deleteData(for: userId)
//                } catch {
//                    DispatchQueue.main.async {
//                        self.showAlert(title: "Error", message: "Failed to delete related data: \(error.localizedDescription)")
//                    }
//                    return
//                }
//
//                // 5. Delete user from Supabase Auth
//                do {
//                    try await SupabaseManager.shared.client
//                        .rpc("delete_user_account", params: ["uid": userId.uuidString])
//                        .execute()
//                } catch {
//                    DispatchQueue.main.async {
//                        self.showAlert(title: "Error", message: "Failed to delete user from authentication: \(error.localizedDescription)")
//                    }
//                    return
//                }
//
//                // 6. Clear local data (e.g., UserDefaults)
//                ProfileDataModel.sharedInstance.deleteProfile(userId)
//                TestDataModel.sharedInstance.deleteData(for: userId)
//
//                // 7. Navigate to the main screen after successful deletion
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(
//                        title: "Account Deleted",
//                        message: "Your account has been permanently deleted.",
//                        preferredStyle: .alert
//                    )
//                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
//                        self.navigateToMainPage()  // Or your desired navigation
//                    })
//                    self.present(alert, animated: true)
//                }
//            }
//        })
//
//        present(alertController, animated: true)
//    }
//
//
//    
//    
//    @IBAction func logOut(_ sender: Any) {
//        let alertController = UIAlertController(
//            title: "Log Out",
//            message: "Are you sure you want to log out?",
//            preferredStyle: .alert
//        )
//
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
//            Task {
//                do {
//                    try await SupabaseManager.shared.auth.signOut()
//                    
//                    DispatchQueue.main.async {
//                        self.navigateToMainPage()
//                    }
//                } catch {
//                    DispatchQueue.main.async {
//                        self.showAlert(title: "Error", message: "Failed to log out. Please try again.")
//                    }
//                }
//            }
//        })
//
//        present(alertController, animated: true)
//    }
//    
//    
//    
//
//    func navigateToMainPage() {
//        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let mainViewController = storyboard.instantiateInitialViewController()
//        sceneDelegate.window?.rootViewController = mainViewController
//        sceneDelegate.window?.makeKeyAndVisible()
//    }
//
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//
//
//
//


import UIKit

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: - UI Elements
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 1.5
        iv.layer.borderColor = UIColor.systemGray4.cgColor
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let updateProfileImageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Update Profile Image", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
     let nameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Enter your name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let pushNotificationCell: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let pushNotificationLabel: UILabel = {
        let label = UILabel()
        label.text = "Allow Push Notifications"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let pushNotificationSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    private let logOutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Log Out", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let deleteAccountButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Delete Account", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.title = "Edit Profile"
        
        
        // Light grey background for all three cells
        let cellBackgroundColor = UIColor.systemGray4.withAlphaComponent(0.2)

        pushNotificationCell.backgroundColor = cellBackgroundColor
        logOutButton.backgroundColor = cellBackgroundColor
        deleteAccountButton.backgroundColor = cellBackgroundColor

        // Left align Delete Account and Log Out button text
        logOutButton.contentHorizontalAlignment = .left
        deleteAccountButton.contentHorizontalAlignment = .left

        // Add some padding on the left to look nicer
        logOutButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        deleteAccountButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

        // Set red text color
        logOutButton.setTitleColor(.systemRed, for: .normal)
        deleteAccountButton.setTitleColor(.systemRed, for: .normal)

        
        setupSubviews()
        setupConstraints()
        setupActions()
        loadUserProfile()
        nameTextField.delegate = self
        
        // Rounded image after layout
        view.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.1
    }
    
    // MARK: - Setup UI
    
    private func setupSubviews() {
        view.addSubview(profileImageView)
        view.addSubview(updateProfileImageButton)
        view.addSubview(nameTextField)
        
        view.addSubview(pushNotificationCell)
        pushNotificationCell.addSubview(pushNotificationLabel)
        pushNotificationCell.addSubview(pushNotificationSwitch)
        
        view.addSubview(logOutButton)
        view.addSubview(deleteAccountButton)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            
            // Update Profile Image Button
            updateProfileImageButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            updateProfileImageButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            // Name TextField
            nameTextField.topAnchor.constraint(equalTo: updateProfileImageButton.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
            nameTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Push Notification Cell
            pushNotificationCell.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 100),
            pushNotificationCell.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            pushNotificationCell.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            pushNotificationCell.heightAnchor.constraint(equalToConstant: 50),
            
            // Push Notification Label
            pushNotificationLabel.centerYAnchor.constraint(equalTo: pushNotificationCell.centerYAnchor),
            pushNotificationLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            
            // Push Notification Switch
            pushNotificationSwitch.centerYAnchor.constraint(equalTo: pushNotificationCell.centerYAnchor),
            pushNotificationSwitch.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            // Log Out Button
            logOutButton.topAnchor.constraint(equalTo: pushNotificationCell.bottomAnchor, constant: 10),
            logOutButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0),
            logOutButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -0),
            logOutButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Delete Account Button
            deleteAccountButton.topAnchor.constraint(equalTo: logOutButton.bottomAnchor, constant: 10),
            deleteAccountButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0),
            deleteAccountButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -0),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupActions() {
        updateProfileImageButton.addTarget(self, action: #selector(updateProfileImageTapped), for: .touchUpInside)
        pushNotificationSwitch.addTarget(self, action: #selector(pushNotificationSwitchChanged), for: .valueChanged)
        logOutButton.addTarget(self, action: #selector(logOutButtonTapped(_:)), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Load User Data
    
    private func loadUserProfile() {
        guard let currentUser = ProfileDataModel.sharedInstance.getCurrentUserProfile() else { return }

        if let imageBase64 = currentUser.image,
           let imageData = Data(base64Encoded: imageBase64),
           let image = UIImage(data: imageData) {
            profileImageView.image = image
        } else {
            profileImageView.image = UIImage(systemName: "person.fill")
        }

        pushNotificationSwitch.isOn = currentUser.notifications
        nameTextField.text = currentUser.name
    }
    
    // MARK: - Actions
    
    @objc private func updateProfileImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true)
            })
        }

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true)
            })
        }
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = updateProfileImageButton
            popoverController.sourceRect = updateProfileImageButton.bounds
        }

        present(alertController, animated: true)
    }
    
    @objc private func pushNotificationSwitchChanged() {
        // Update model when switch changes
        // Assuming update happens on save - you can implement live update here if needed
    }
    
    @objc private func logOutButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            Task { @MainActor in
                print("Logging out...")
                do {
                    try await SupabaseManager.shared.auth.signOut()
                    self.navigateToMainPage()
                } catch {
                    self.showAlert(title: "Error", message: "Failed to log out. Please try again.")
                }
            }
        })

        present(alertController, animated: true)
    }

    
    @objc private func deleteAccountButtonTapped(_ sender: UIButton) {
        // Reuse your existing delete account logic here
        guard let currentUser = ProfileDataModel.sharedInstance.getCurrentUserProfile() else { return }

        let alertController = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to permanently delete your account? This cannot be undone.",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Task {
                let userId = currentUser.id

                do {
                    try await SupabaseManager.shared.client
                        .from("user_test_progress")
                        .delete()
                        .eq("user_id", value: userId.uuidString)
                        .execute()
                } catch {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to delete progress data: \(error.localizedDescription)")
                    }
                    return
                }

                do {
                    try await SupabaseManager.shared.auth.signOut()
                } catch {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to sign out: \(error.localizedDescription)")
                    }
                    return
                }

                do {
                    try await SupabaseManager.shared.client
                        .from("profiles")
                        .delete()
                        .eq("id", value: userId)
                        .execute()
                } catch {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to delete profile: \(error.localizedDescription)")
                    }
                    return
                }

                do {
                    await AchievementDataModel.sharedInstance.deleteData(for: userId)
                    BadgesDataModel.sharedInstance.deleteData(for: userId)
                    JourneyDataModel.shared.deleteData(for: userId)
                    BookMarkedWords.sharedInstance.deleteData(for: userId)
                } catch {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to delete related data: \(error.localizedDescription)")
                    }
                    return
                }

                do {
                    try await SupabaseManager.shared.client
                        .rpc("delete_user_account", params: ["uid": userId.uuidString])
                        .execute()
                } catch {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to delete user from authentication: \(error.localizedDescription)")
                    }
                    return
                }

                ProfileDataModel.sharedInstance.deleteProfile(userId)
                TestDataModel.sharedInstance.deleteData(for: userId)

                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Account Deleted",
                        message: "Your account has been permanently deleted.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.navigateToMainPage()
                    })
                    self.present(alert, animated: true)
                }
            }
        })

        present(alertController, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
        }
        picker.dismiss(animated: true)
    }
    
    // MARK: - Helpers
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let updatedName = nameTextField.text,
              !updatedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(title: "Missing Name", message: "Please enter a valid name.")
            return
        }

        guard let updatedImage = profileImageView.image,
              let imageData = updatedImage.jpegData(compressionQuality: 0.8) else {
            showAlert(title: "Missing Image", message: "Please select a profile image.")
            return
        }

        let imageBase64 = imageData.base64EncodedString()
        guard var currentUser = ProfileDataModel.sharedInstance.getCurrentUserProfile() else { return }

        currentUser.name = updatedName
        currentUser.notifications = pushNotificationSwitch.isOn
        currentUser.image = imageBase64

        ProfileDataModel.sharedInstance.updateProfileDataFromBase64(
            updatedName,
            imageBase64,
            pushNotificationSwitch.isOn  // <-- Use the switch here, NOT the UIView
        ) 
    }
    
    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true)
    }
    
    private func navigateToMainPage() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateInitialViewController()
                sceneDelegate.window?.rootViewController = mainViewController
                sceneDelegate.window?.makeKeyAndVisible()
    }
}
