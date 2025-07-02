import UIKit

private let reuseIdentifier = "TestListCell"

private var celltapped = 0
private var currentUserId: UUID?
var filteredTests: [Test] = []



class CircularProgressView: UIView {
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()
    fileprivate var didConfigureLabel = false
    fileprivate var rounded: Bool
    fileprivate var filled: Bool
    
    fileprivate let lineWidth: CGFloat?
    
    var timeToFill = 1.1
    
    var progressColor = UIColor.white {
        didSet{
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor.white {
        didSet{
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var progress: Float {
        didSet{
            var pathMoved = progress - oldValue
            if pathMoved < 0 {
                pathMoved = 0 - pathMoved
            }
            setProgress(duration: timeToFill * Double(pathMoved), to: progress)
        }
    }
    
    fileprivate func createProgressView(){
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = frame.size.width / 2
        let circularPath = UIBezierPath(arcCenter: center, radius: frame.width / 2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.fillColor = UIColor.blue.cgColor
        
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = .none
        trackLayer.strokeColor = trackColor.cgColor
        if filled {
            trackLayer.lineCap = .butt
            trackLayer.lineWidth = frame.width
        }else{
            trackLayer.lineWidth = lineWidth!
        }
        trackLayer.strokeEnd = 1
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = .none
        progressLayer.strokeColor = progressColor.cgColor
        if filled {
            progressLayer.lineCap = .butt
            progressLayer.lineWidth = frame.width
        }else{
            progressLayer.lineWidth = lineWidth!
        }
        progressLayer.strokeEnd = 0
        if rounded{
            progressLayer.lineCap = .round
        }
        
        layer.addSublayer(progressLayer)
        
    }
    
    func trackColorToProgressColor() -> Void{
        trackColor = progressColor
        trackColor = UIColor(red: progressColor.cgColor.components![0], green: progressColor.cgColor.components![1], blue: progressColor.cgColor.components![2], alpha: 0.2)
    }
    
    func setProgress(duration: TimeInterval = 3, to newProgress: Float) -> Void{
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = newProgress
        
        progressLayer.strokeEnd = CGFloat(newProgress)
        
        progressLayer.add(animation, forKey: "animationProgress")
        
    }
    
    override init(frame: CGRect){
        progress = 0
        rounded = true
        filled = false
        lineWidth = 15
        super.init(frame: frame)
        filled = false
        createProgressView()
    }
    
    required init?(coder: NSCoder) {
        progress = 0
        rounded = true
        filled = false
        lineWidth = 15
        super.init(coder: coder)
        createProgressView()
    }
    
    init(frame: CGRect, lineWidth: CGFloat?, rounded: Bool) {
        progress = 0
        
        if lineWidth == nil{
            self.filled = true
            self.rounded = false
        }else{
            if rounded{
                self.rounded = true
            }else{
                self.rounded = false
            }
            self.filled = false
        }
        self.lineWidth = lineWidth
        
        super.init(frame: frame)
        createProgressView()
    }
}

class TestListCollectionViewController: UICollectionViewController, TestListCollectionViewCellDelegate {
    var testType : TestType?
    var screenTitle : String?
    
    var loadingIndicator: UIActivityIndicatorView?

    func showLoadingIndicator() {
        if loadingIndicator == nil {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.center = self.view.center
            indicator.color = .systemBlue
            indicator.hidesWhenStopped = true
            self.view.addSubview(indicator)
            loadingIndicator = indicator
        }
        loadingIndicator?.startAnimating()
    }

    func hideLoadingIndicator() {
        if let indicator = loadingIndicator {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
                loadingIndicator = nil
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideLoadingIndicator()
    }


    
    func testStart(testID : Int, buttonNumber : Int) {
        
        guard let userId = currentUserId else {
               // maybe show an error or return
               return
           }
           
           Task {
               let canStart = await canUserStartTest(userId: userId, testID: testID)
               DispatchQueue.main.async {
                   if canStart {
                       self.showStartTestConfirmation(testID: testID, buttonNumber: buttonNumber)
                   } else {
                       self.showLockedAlert(forTestID: testID)
                   }
               }
           }
//        let alertController = UIAlertController(title: "Start Test ?", message: nil, preferredStyle: .alert)
////        let yes = UIAlertAction(title: "Yes", style: .default) { _ in
////            self.performSegue(withIdentifier: "TestStart", sender: testID)
////        }
//        let yes = UIAlertAction(title: "Yes", style: .default) { _ in
//            self.showLoadingIndicator()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.performSegue(withIdentifier: "TestStart", sender: testID)
//            }
//        }
//
//        
//        let no = UIAlertAction(title: "No", style: .destructive) { _ in }
//    
//        celltapped = buttonNumber
//        
//        alertController.addAction(no)
//        alertController.addAction(yes)
//        present(alertController, animated: true)
    }
    
    @IBSegueAction func TestStart(_ coder: NSCoder, sender: Any?) -> TestStartNavigationViewController? {
        guard let destination = TestStartNavigationViewController(coder: coder),
              let childVC = destination.topViewController as? TestPageViewController
        else { return nil }
        
        guard let sender =  sender as? Int else { return nil }
        
        childVC.test = TestDataModel.sharedInstance.giveTest(by: sender, type: testType!)
        return destination
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            
            var section : NSCollectionLayoutSection
            switch sectionIndex {
                
            case 0:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(200)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                item.contentInsets = NSDirectionalEdgeInsets(
                    top : 5,
                    leading: 10,
                    bottom: 0,
                    trailing: 10
                )
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(0.25))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                
            default:
                return nil
                
            }
            return section
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = screenTitle
        
        collectionView.collectionViewLayout = createCompositionalLayout()
        filteredTests = TestDataModel.sharedInstance.getTestsByType(type: testType!)
        
        if currentUserId == nil {
            currentUserId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
        }
        
        if let userId = currentUserId {
            Task {
                await TestDataModel.sharedInstance.fetchUserProgress(userId: userId)
                await MainActor.run {
                    self.collectionView.reloadData()
                }
            }
        }
        hideLoadingIndicator()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func canUserStartTest(userId: UUID, testID: Int) async -> Bool {
        // Example: fetch completed exercises count for test's section or criteria
        // You probably need to get the sectionTitle for the testID first, e.g.:
        guard let test = filteredTests.first(where: { $0.testID == testID }) else {
            return false
        }

        let completedCount = await JourneyDataModel.shared.completedExercisesCount(for: userId, in: test.title)
        return completedCount >= 5
    }

    func showStartTestConfirmation(testID: Int, buttonNumber: Int) {
        let alertController = UIAlertController(title: "Start Test?", message: nil, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { _ in
            self.showLoadingIndicator()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.performSegue(withIdentifier: "TestStart", sender: testID)
            }
        }
        let no = UIAlertAction(title: "No", style: .destructive, handler: nil)
        alertController.addAction(no)
        alertController.addAction(yes)
        self.present(alertController, animated: true)
        celltapped = buttonNumber
    }

    func showLockedAlert(forTestID testID: Int) {
        guard let test = filteredTests.first(where: { $0.testID == testID }) else { return }
        let alert = UIAlertController(title: "Locked",
                                      message: "Complete at least 5 signs in \(test.title) to unlock this test.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return TestDataModel.sharedInstance.giveTestCount(testType: testType!)
//    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTests.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let currentUserId = currentUserId else {
            return UICollectionViewCell()
        }
        
//        let test = TestDataModel.sharedInstance.giveTest(by: ((testType! == .classic ? 10 : 20) + indexPath.item + 1), type: (testType!))
        let test = filteredTests[indexPath.item]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TestListCollectionViewCell
        
        cell.layer.borderColor = test.themeColor?.uiColor.cgColor
        cell.layer.borderWidth = 3
        cell.layer.cornerRadius = 20
        
        if(test.title == "Coming Soon"){
            cell.newTestLabel.isHidden = true
            cell.testNameLabel.isHidden = true
            cell.progressBarView.isHidden = true
            cell.testDescriptionLabel.isHidden = true
            cell.testButton.isHidden = true
            cell.ComingSoonLabel.isHidden = false
            return cell
        }
        
        let progressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), lineWidth: 15, rounded: true)
        progressView.progressColor = test.themeColor!.uiColor
        progressView.trackColor = .systemGray2

//        let cachedScore = TestDataModel.sharedInstance.getScore(for: currentUserId, testId: test!.id)
//        let questionCount = test!.questions.count
//
//        progressView.progress = Float(cachedScore) / Float(questionCount)
//        cell.testProgress.text = "\(cachedScore)/\(questionCount)"
//
//        Task {
//            let cellIndexPath = indexPath
//
//            let latestScore = await TestDataModel.sharedInstance.getLatestScore(for: currentUserId, testID: test!.testID!)
//
//            await MainActor.run {
//                if collectionView.indexPathsForVisibleItems.contains(cellIndexPath) {
//                    if latestScore != cachedScore {
//                        progressView.progress = Float(latestScore) / Float(questionCount)
//                        cell.testProgress.text = "\(latestScore)/\(questionCount)"
//                    }
//                }
//            }
        
        let questionCount = test.questions.count
        cell.testProgress.text = "..."

        Task {
            let cellIndexPath = indexPath

//            let latestScore = await TestDataModel.sharedInstance.getLatestScore(for: currentUserId, testID: test.testID!
            let latestScore = await TestDataModel.sharedInstance.getLatestScore(for: currentUserId, testID: test.testID!, forceRefresh: true)


            await MainActor.run {
                if collectionView.indexPathsForVisibleItems.contains(cellIndexPath) {
                    progressView.progress = Float(latestScore) / Float(questionCount)
                    cell.testProgress.text = "\(latestScore)/\(questionCount)"
                }
            }
        }
        
        cell.ComingSoonLabel.isHidden = true
        cell.testNameLabel.text = test.title
        cell.testDescriptionLabel.text = test.description
        cell.progressBarView.addSubview(progressView)
        cell.testNameLabel.textColor = test.themeColor?.uiColor
        cell.newTestLabel.isHidden = (test.newTest == true ? false : true)
        cell.newTestLabel.backgroundColor = test.themeColor?.uiColor
        cell.newTestLabel.layer.cornerRadius = 30
        cell.testButton.tag = indexPath.item
        cell.delegate = self
        cell.testID = test.testID!
       
        return cell
    }
    
    @IBAction func unwindToTestList(_ segue: UIStoryboardSegue) {
//        if let userId = currentUserId {
//            Task {
//                
//                await TestDataModel.sharedInstance.fetchUserProgress(userId: userId)
//                filteredTests = TestDataModel.sharedInstance.getTestsByType(type: testType!)
//                await MainActor.run {
//                      collectionView.reloadData()
//                      collectionView.reloadItems(at: [IndexPath(item:celltapped, section: 0)])
//                }
//            }
//        }
        if let userId = currentUserId {
            hideLoadingIndicator()
                Task {
                    await TestDataModel.sharedInstance.fetchUserProgress(userId: userId)
                    filteredTests = TestDataModel.sharedInstance.getTestsByType(type: testType!)
                    
                    await MainActor.run {
                        collectionView.reloadData()

                        if celltapped >= 0, celltapped < filteredTests.count {
                            collectionView.reloadItems(at: [IndexPath(item: celltapped, section: 0)])
                        }
                    }
                }
            }
    }
    
    func updateProgressBar(for testID: Int, in cell: TestListCollectionViewCell) {
        if currentUserId == nil {
            currentUserId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
        }

        guard let userId = currentUserId else {
            return
        }

        Task {
            do {
                let latestScore = await TestDataModel.sharedInstance.getLatestScore(for: userId, testID: testID)

                DispatchQueue.main.async {
                    if let progressView = cell.progressBarView.subviews.first as? CircularProgressView {
                        progressView.progress = Float(latestScore) / Float(100)
                    }
                }
            } catch {
                // Handle the error as needed
            }
        }
    }
}

