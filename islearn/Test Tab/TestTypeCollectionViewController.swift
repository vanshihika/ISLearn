import UIKit

private let reuseIdentifier = "TestTypeCell"
private let reuseHeaderIdentifier = "Header"

class TestTypeCollectionViewController: UICollectionViewController {
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            guard sectionIndex == 0 else { return nil }
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(0.3)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TestTypeCollectionViewCell
        
        switch indexPath.item {
        case 0:
            cell.testTypeImage.image = UIImage(systemName: "graduationcap.fill")
            cell.testTypeName.text = "Classic Tests"
            cell.testTypeDescription.text = "Practice learnt concepts and earn XP"
//        case 1:
//            cell.testTypeImage.image = UIImage(systemName: "hand.wave.fill")
//            cell.testTypeName.text = "Gesture Tests"
//            cell.testTypeDescription.text = "Gain proficiency in gestures and earn XP"
        default:
            cell.testTypeImage.image = UIImage(systemName: "hand.wave")
            cell.testTypeName.text = "Default Tests"
            cell.testTypeDescription.text = "Nothing"
        }
        
        cell.testTypeImage.layer.shadowOpacity = 0.5
        cell.testTypeImage.layer.shadowOffset = CGSize(width: 5, height: 10)
        cell.layer.cornerRadius = 20
        cell.testTypeDescription.textColor = .systemGray
        cell.chevronSymbol.titleLabel?.text = ""
        cell.chevronSymbol.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? TestListCollectionViewController,
              let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        
        switch indexPath.item {
        case 0:
            destinationVC.screenTitle = "Classic Test"
            destinationVC.testType = .classic
        case 1:
            destinationVC.screenTitle = "Gesture Test"
            destinationVC.testType = .gesture
        default:
            destinationVC.screenTitle = ""
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath)
        
        header.subviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.text = "Choose a type of test"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .natural
        label.textColor = .accent
        label.translatesAutoresizingMaskIntoConstraints = false
        
        header.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: header.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8)
        ])
        
        return header
    }
}

