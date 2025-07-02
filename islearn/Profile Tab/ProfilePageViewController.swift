import UIKit

class ProfilePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var achievementsCollection: UICollectionView!
    @IBOutlet weak var badgesCollection: UICollectionView!
    @IBOutlet weak var longestStreakLabel: UILabel!
    @IBOutlet weak var learnedWordsLabel: UILabel!
    @IBOutlet weak var totalExperienceLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileLoad()
        
        badgesCollection.delegate = self
        badgesCollection.dataSource = self
        
        achievementsCollection.delegate = self
        achievementsCollection.dataSource = self
        
        setupStreakLabel()
        setupTotalExperienceLabel()
        setupLearnedWordsLabel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBadgesCollectionView), name: NSNotification.Name("BadgeUpdated"), object: nil)
    }

    @objc func reloadBadgesCollectionView() {
        badgesCollection.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await AchievementDataModel.sharedInstance.syncFromSupabase()
            await MainActor.run {
                print("🔁 Reloading achievements collection after sync")
                self.achievementsCollection.reloadData()
            }
        }
        
        achievementsCollection.reloadData()
        badgesCollection.reloadData()
        setupStreakLabel()
        setupTotalExperienceLabel()
        setupLearnedWordsLabel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
//        imageView.layer.cornerRadius = imageView.frame.size.width / 2
//        imageView.clipsToBounds = true // or imageView.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
        setCollectionViewContentHeight()
    }

    func setupStreakLabel() {
        guard let profile = ProfileDataModel.sharedInstance.getCurrentUserProfile() else { return }
        
        let streak = profile.currentStreak
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 27, weight: .regular)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "flame.fill", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
        
        let attributedString = NSMutableAttributedString(string: "\(streak) ")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length - 1))
        
        longestStreakLabel.textColor = .systemOrange
        longestStreakLabel.attributedText = attributedString
        
        Task {
            await BadgesDataModel.sharedInstance.checkAndUnlockBadges(for: profile.id)
            await MainActor.run {
                self.badgesCollection.reloadData()
            }
        }
    }

    func setupTotalExperienceLabel() {
        guard let profile = ProfileDataModel.sharedInstance.getCurrentUserProfile() else { return }

        let points = profile.totalExperiencePoints
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 27, weight: .regular)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "bolt.fill", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
        
        let attributedString = NSMutableAttributedString(string: "\(points) ")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length - 1))
        
        totalExperienceLabel.textColor = .systemYellow
        totalExperienceLabel.attributedText = attributedString
    }

    func setupLearnedWordsLabel() {
        Task {
            guard let userId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id else { return }

            do {
                struct LearnedSignsOnly: Decodable {
                    let learned_signs: [String]?
                }

                let response: [LearnedSignsOnly] = try await SupabaseManager.shared.client
                    .from("profiles")
                    .select("learned_signs")
                    .eq("id", value: userId)
                    .limit(1)
                    .execute()
                    .value

                let count = response.first?.learned_signs?.count ?? 0

                let symbolConfig = UIImage.SymbolConfiguration(pointSize: 27, weight: .regular)
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(systemName: "star.fill", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)

                let attributedString = NSMutableAttributedString(string: "\(count) ")
                attributedString.append(NSAttributedString(attachment: imageAttachment))
                attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length - 1))

                await MainActor.run {
                    learnedWordsLabel.textColor = .systemPurple
                    learnedWordsLabel.attributedText = attributedString
                }

            } catch {
                print("❌ Failed to fetch learned signs: \(error)")
            }
        }
    }

    func profileLoad() {
        guard let profile = ProfileDataModel.sharedInstance.getCurrentUserProfile() else { return }
        profileImage.image = profile.getUIImage() ?? UIImage(systemName: "person.fill")
        userName.text = profile.name
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == badgesCollection {
            return BadgesDataModel.sharedInstance.getBadgesCount()
        } else {
            return AchievementDataModel.sharedInstance.getAchievementCount()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == badgesCollection {
            return CGSize(width: 110, height: 115)
        } else {
            return CGSize(width: 420, height: 125)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return (collectionView == badgesCollection) ? 10 : 30
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == badgesCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "badge", for: indexPath) as? BadgeCollectionViewCell else {
                fatalError("Could not dequeue BadgeCollectionViewCell")
            }
            
            let badge = BadgesDataModel.sharedInstance.getBadgesData(indexPath.item + 1)
            cell.badgeImage.image = UIImage(systemName: "hexagon")
            cell.badgeImage.contentMode = .scaleToFill
            cell.badgeLabel.text = badge?.name ?? ""
            cell.badgeImage.tintColor = (badge?.isCompleted ?? false) ? .systemOrange : .gray
            collectionView.showsHorizontalScrollIndicator = false
            return cell

        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "achievement", for: indexPath) as? AchievementsCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            guard let achievement = AchievementDataModel.sharedInstance.getAchievementData(indexPath.item) else {
                return cell
            }

            let trophyImage = UIImage(systemName: "trophy.fill")
            let emptyTrophy = UIImage(systemName: "trophy")
            cell.MainTrophy.image = emptyTrophy
            cell.bronzeTrophy.image = trophyImage
            cell.silverTrophy.image = trophyImage
            cell.goldTrophy.image = trophyImage
            
            switch achievement.currentLevel {
            case 1:
                cell.MainTrophy.tintColor = .accent
                cell.bronzeTrophy.tintColor = .darkGray
                cell.silverTrophy.tintColor = .darkGray
                cell.goldTrophy.tintColor = .darkGray
            case 2:
                cell.MainTrophy.tintColor = .accent
                cell.bronzeTrophy.tintColor = .maroon
                cell.silverTrophy.tintColor = .darkGray
                cell.goldTrophy.tintColor = .darkGray
            case 3:
                cell.MainTrophy.tintColor = .accent
                cell.bronzeTrophy.tintColor = .maroon
                cell.silverTrophy.tintColor = .silver
                cell.goldTrophy.tintColor = .darkGray
            case 4:
                cell.MainTrophy.image = trophyImage
                cell.MainTrophy.tintColor = .accent
                cell.bronzeTrophy.tintColor = .maroon
                cell.silverTrophy.tintColor = .silver
                cell.goldTrophy.tintColor = .golden
            default:
                cell.MainTrophy.tintColor = .darkGray
                cell.bronzeTrophy.tintColor = .darkGray
                cell.silverTrophy.tintColor = .darkGray
                cell.goldTrophy.tintColor = .darkGray
            }

            let progressValue = Float(achievement.currentProgress) / Float(achievement.maxProgress)
            cell.achievementProgress.progress = progressValue
            
            cell.achievementTitle.text = achievement.name
            cell.achievementDetail.text = achievement.description
            achievementsCollection.showsVerticalScrollIndicator = false
            
            return cell
        }
    }

    @IBAction func unwindToProfileViewController(segue: UIStoryboardSegue) {
        guard let sourceVC = segue.source as? ProfileEditViewController,
                  let image = sourceVC.profileImageView.image,
                  let name = sourceVC.nameTextField.text else { return }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data")
            return
        }
        let base64String = imageData.base64EncodedString()

        ProfileDataModel.sharedInstance.updateProfileDataFromBase64(
            name,
            base64String,
            sourceVC.pushNotificationSwitch.isOn
        )

        profileImage.image = image
        userName.text = name
    }
    
    @IBAction func unwindToCancelProfileViewControllerWithSegue(segue: UIStoryboardSegue) {
        print("Unwind segue triggered from cancel.")
    }


    func setCollectionViewContentHeight() {
        let contentHeight = achievementsCollection.collectionViewLayout.collectionViewContentSize.height
        achievementsCollection.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
    }
}
