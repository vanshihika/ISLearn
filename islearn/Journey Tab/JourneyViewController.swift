import UIKit

class JourneyViewController: UIViewController, UIScrollViewDelegate {
    var currentUserId: UUID!
    var numberRectangularButton = RectangularButton(color: Color(uiColor: .red), title: "Numbers", description: "Get your numbers right!")
    var alphabetRectangularButton = RectangularButton(color: Color(uiColor: .themeColor), title: "Alphabets", description: "Learn your alphabets in a fun and interactive way!")
    var loaderView: UIActivityIndicatorView!
    
    let buttonSize: CGFloat = 100
    let padding: CGFloat = 30
    var scrollView: UIScrollView!
    
    var alphabetButtons: [UIButton] = []
    var numberButtons: [UIButton] = []
    
    var currentYPosition: CGFloat = 0
    var numberSectionY: CGFloat = 0
    var lineLayers: [CAShapeLayer] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        currentUserId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
        
        showLoader(true)
        
        Task {
            guard let currentUserId = currentUserId else {
                showLoader(false)
                return
            }

            do {
                let userJourney = try await JourneyDataModel.shared.getJourney(for: currentUserId)

                await setupScrollView(journey: userJourney)
                
                setupRectangularButtons(buttonInfo: alphabetRectangularButton, startY: padding)
                if userJourney.section.count > 0 {
                    alphabetButtons = await setupCircularButtons(for: userJourney.section[0].exercises, sectionTitle: "Alphabets", color: .themeColor, offsetY: currentYPosition)
                }
                
                currentYPosition += padding
                
                setupRectangularButtons(buttonInfo: numberRectangularButton, startY: currentYPosition)
                if userJourney.section.count > 1 {
                    numberButtons = await setupCircularButtons(for: userJourney.section[1].exercises, sectionTitle: "Numbers", color: .red, offsetY: currentYPosition)
                }

                drawLinesBetweenButtons(from: alphabetButtons)
                drawLinesBetweenButtons(from: numberButtons)
                
            } catch {
                
            }
            showLoader(false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task {
            if currentUserId == nil {
                currentUserId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
            }

            guard let currentUserId = currentUserId else { return }

            view.backgroundColor = .black

            do {
                let userJourney = try await JourneyDataModel.shared.getJourney(for: currentUserId, forceRefresh: true)

                for (sectionIndex, section) in userJourney.section.enumerated() {
                    let sectionTitle = section.title

                    await self.updateExerciseButtons(forSectionTitle: sectionTitle)

                    if let firstExercise = section.exercises.first {
                        let isLocked = try await JourneyDataModel.shared.isExerciseLocked(for: currentUserId, sectionTitle: sectionTitle, exerciseName: firstExercise.name)

                        if !isLocked {
                            DispatchQueue.main.async {
                                let firstButton = sectionTitle == "Alphabets" ? self.alphabetButtons.first : self.numberButtons.first
                                firstButton?.isEnabled = true
                                firstButton?.backgroundColor = sectionTitle == "Alphabets" ? .themeColor : .red
                            }
                        }
                    }

                    if let lastExercise = section.exercises.last,
                       try await JourneyDataModel.shared.isExerciseCompleted(for: currentUserId, sectionTitle: sectionTitle, exerciseName: lastExercise.name),
                       sectionIndex + 1 < userJourney.section.count {

                        let nextSection = userJourney.section[sectionIndex + 1]
                        if let nextExercise = nextSection.exercises.first {
                            DispatchQueue.main.async {
                                let nextSectionButton = nextSection.title == "Alphabets" ? self.alphabetButtons.first : self.numberButtons.first
                                nextSectionButton?.isEnabled = true
                                nextSectionButton?.backgroundColor = nextSection.title == "Alphabets" ? .themeColor : .red
                            }
                        }
                    }
                }
            } catch {
                // Handle error if needed
            }
        }
    }

    func setupScrollView(journey: Journey) async {
        scrollView = UIScrollView()
        scrollView.frame = view.bounds
        scrollView.delegate = self

        view.addSubview(scrollView)

        let contentView = UIView()
        scrollView.addSubview(contentView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        let totalHeight = CGFloat(journey.section.reduce(0) { $0 + $1.exercises.count }) * (buttonSize + padding) + padding + 400
        contentView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: totalHeight)
        scrollView.contentSize = CGSize(width: view.frame.width, height: totalHeight)
    }

    func setupRectangularButtons(buttonInfo: RectangularButton, startY: CGFloat) {
        guard let contentView = scrollView.subviews.first else { return }
        
        let rectangularButton = UIButton()
        rectangularButton.backgroundColor = buttonInfo.color.uiColor
        rectangularButton.layer.cornerRadius = 8
        rectangularButton.frame = CGRect(x: padding, y: startY, width: scrollView.frame.width - 2 * padding, height: 100)
        contentView.addSubview(rectangularButton)
        
        let titleLabel = UILabel()
        titleLabel.text = buttonInfo.title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.frame = CGRect(x: 20, y: 10, width: rectangularButton.frame.width - 40, height: 30)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = buttonInfo.description
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionLabel.frame = CGRect(x: 20, y: 40, width: rectangularButton.frame.width - 40, height: 50)
        
        rectangularButton.addSubview(titleLabel)
        rectangularButton.addSubview(descriptionLabel)
        currentYPosition = startY + rectangularButton.frame.height + padding
    }
    
    func setupCircularButtons(for exercises: [Exercise], sectionTitle: String, color: UIColor, offsetY: CGFloat) async -> [UIButton] {
        guard let contentView = scrollView.subviews.first else { return [] }
        var buttons: [UIButton] = []
        var currentYPosition = offsetY
        
        for (index, exercise) in exercises.enumerated() {
            let button = UIButton()
            let completed = await JourneyDataModel.shared.isExerciseCompleted(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
            let isLocked = await JourneyDataModel.shared.isExerciseLocked(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)

            button.setTitle("\(exercise.name)\(completed ? " ✓" : (isLocked ? " 􀎡" : ""))", for: .normal)
            button.backgroundColor = isLocked ? .gray : color
            button.isEnabled = !isLocked
            button.layer.cornerRadius = buttonSize / 2
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            let x: CGFloat = index % 2 == 0 ? padding : view.frame.width - padding - buttonSize
            button.frame = CGRect(x: x, y: currentYPosition, width: buttonSize, height: buttonSize)
            
            contentView.addSubview(button)
            buttons.append(button)
            
            currentYPosition += buttonSize + padding
        }
        
        self.currentYPosition = currentYPosition
        return buttons
    }
    
    func updateExerciseButtons(forSectionTitle sectionTitle: String) async {
        let userJourney = try? await JourneyDataModel.shared.getJourney(for: currentUserId, forceRefresh: true)

        guard let section = userJourney?.section.first(where: { $0.title == sectionTitle }) else { return }

        var buttonArray: [UIButton] = []

        if sectionTitle == "Alphabets" {
            buttonArray = alphabetButtons
        } else if sectionTitle == "Numbers" {
            buttonArray = numberButtons
        }

        for (index, exercise) in section.exercises.enumerated() {
            guard index < buttonArray.count else { continue }

            let completed = try? await JourneyDataModel.shared.isExerciseCompleted(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
            let isLocked = try? await JourneyDataModel.shared.isExerciseLocked(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)

            await MainActor.run {
                let button = buttonArray[index]
                let newTitle = (completed ?? false) ? "\(exercise.name) ✓" : exercise.name
                let attributedTitle = NSMutableAttributedString(string: newTitle)

                if isLocked == true, let lockImage = UIImage(systemName: "lock.fill") {
                    let lockAttachment = NSTextAttachment()
                    lockAttachment.image = lockImage.withTintColor(.white, renderingMode: .alwaysOriginal)
                    lockAttachment.bounds = CGRect(x: 0, y: -3, width: 25, height: 27)

                    let lockString = NSAttributedString(attachment: lockAttachment)
                    attributedTitle.append(NSAttributedString(string: " "))
                    attributedTitle.append(lockString)
                }

                button.setAttributedTitle(attributedTitle, for: .normal)

                if completed == true && index + 1 < buttonArray.count {
                    let nextButton = buttonArray[index + 1]
                    nextButton.isEnabled = true
                    nextButton.backgroundColor = sectionTitle == "Alphabets" ? .themeColor : .red
                }
            }
        }
    }

    @objc func buttonTapped(_ sender: UIButton) {
        Task {
            guard let currentUserId = currentUserId else { return }
            
            let sectionTitle = alphabetButtons.contains(sender) ? "Alphabets" : "Numbers"
            let exerciseIndex = sender.tag

            do {
                let userJourney = try await JourneyDataModel.shared.getJourney(for: currentUserId, forceRefresh: true)
                let exercises = userJourney.section.first(where: { $0.title == sectionTitle })?.exercises ?? []
                
                guard exerciseIndex < exercises.count else { return }
                let exercise = exercises[exerciseIndex]

                let completed = await JourneyDataModel.shared.isExerciseCompleted(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
                
                if completed {
                    if exerciseIndex + 1 < exercises.count {
                        let nextButton = alphabetButtons.contains(sender) ?
                            (exerciseIndex + 1 < alphabetButtons.count ? alphabetButtons[exerciseIndex + 1] : nil) :
                            (exerciseIndex + 1 < numberButtons.count ? numberButtons[exerciseIndex + 1] : nil)

                        nextButton?.isEnabled = true
                        nextButton?.backgroundColor = alphabetButtons.contains(sender) ? .themeColor : .red
                    }
                }

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toUnitViewController", sender: [exercise, sectionTitle, currentUserId])
                }
            } catch {
                // Handle error if needed
            }
        }
    }

    @IBSegueAction func toNextUnit(_ coder: NSCoder, sender: Any?) -> UnitViewController? {
        let nextVC = UnitViewController(coder: coder)
        nextVC!.sectionTitle = (sender as! [Any])[1] as! String
        nextVC!.exercise = (sender as! [Any])[0] as! Exercise
        nextVC!.currentUserId = (sender as! [Any])[2] as! UUID
        return nextVC
    }
    
    func drawLinesBetweenButtons(from buttons: [UIButton]) {
        guard let contentView = scrollView.subviews.first else { return }
        var previousButton: UIButton? = nil
        
        for i in 0..<buttons.count {
            let currentButton = buttons[i]
            if let previousButton = previousButton {
                let startPoint = CGPoint(x: previousButton.center.x, y: previousButton.center.y)
                let endPoint = CGPoint(x: currentButton.center.x, y: currentButton.center.y)
                let lineLayer = drawLine(from: startPoint, to: endPoint, in: contentView)
                lineLayers.append(lineLayer)
            }
            previousButton = currentButton
        }
        for button in buttons {
            button.superview?.bringSubviewToFront(button)
        }
    }
    
    func drawLine(from startPoint: CGPoint, to endPoint: CGPoint, in view: UIView) -> CAShapeLayer {
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = linePath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        view.layer.addSublayer(shapeLayer)
        return shapeLayer
    }
    
    func showLoader(_ show: Bool) {
        if loaderView == nil {
            loaderView = UIActivityIndicatorView(style: .large)
            loaderView.color = .white
            loaderView.translatesAutoresizingMaskIntoConstraints = false
            loaderView.hidesWhenStopped = true
            view.addSubview(loaderView)

            NSLayoutConstraint.activate([
                loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }

        if show {
            view.isUserInteractionEnabled = false
            loaderView.startAnimating()
        } else {
            view.isUserInteractionEnabled = true
            loaderView.stopAnimating()
        }
    }
}

