import Foundation
import UIKit

class GuestJourneyViewController: UIViewController, UIScrollViewDelegate {
    var currentUserId: UUID!
    var alphabetRectangularButton = RectangularButton(color: Color(uiColor: .themeColor), title: "Alphabets", description: "Learn your alphabets in a fun and interactive way!")
    
    let buttonSize: CGFloat = 100
    let padding: CGFloat = 30
    var scrollView: UIScrollView!
    
    var alphabetButtons: [UIButton] = []
    var currentYPosition: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Journey"
        
        view.backgroundColor = .black
        
        Task {
            do {
                let guestJourney = try await GuestJourneyDataModel.shared.getGuestJourney()
                await setupScrollView(journey: guestJourney)
                
                setupRectangularButtons(buttonInfo: alphabetRectangularButton, startY: padding)
                if let alphabetsSection = guestJourney.section.first {
                    alphabetButtons = setupCircularButtons(for: alphabetsSection.exercises, sectionTitle: "Alphabets", color: .themeColor, offsetY: currentYPosition)
                }
                
                drawLinesBetweenButtons(from: alphabetButtons)
            } catch {
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
    
    func setupCircularButtons(for exercises: [Exercise], sectionTitle: String, color: UIColor, offsetY: CGFloat) -> [UIButton] {
        guard let contentView = scrollView.subviews.first else { return [] }
        var buttons: [UIButton] = []
        var currentYPosition = offsetY
        
        // Limit to the first 8 exercises
        let firstEightExercises = exercises.prefix(8)
        
        for (index, exercise) in firstEightExercises.enumerated() {
            let button = UIButton()

            // Make all exercises unlocked (interactive)
            button.setTitle(exercise.name, for: .normal)
            button.backgroundColor = color
            button.isEnabled = true  // Make buttons interactive
            button.layer.cornerRadius = buttonSize / 2
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            button.tag = index
            
            let x: CGFloat = index % 2 == 0 ? padding : view.frame.width - padding - buttonSize
            button.frame = CGRect(x: x, y: currentYPosition, width: buttonSize, height: buttonSize)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

            
            contentView.addSubview(button)
            buttons.append(button)
            
            currentYPosition += buttonSize + padding
        }
        
        self.currentYPosition = currentYPosition
        return buttons
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

    @objc func buttonTapped(_ sender: UIButton) {
        Task {
            let sectionTitle = alphabetButtons.contains(sender) ? "Alphabets" : "Numbers"
            let exerciseIndex = sender.tag

            do {
                let guestJourney = try await GuestJourneyDataModel.shared.getGuestJourney()
                let exercises = guestJourney.section.first(where: { $0.title == sectionTitle })?.exercises ?? []

                guard exerciseIndex < exercises.count else { return }
                let exercise = exercises[exerciseIndex]

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toUnitViewController", sender: [exercise, sectionTitle])
                }
            } catch {
                print("Failed to load guest journey: \(error.localizedDescription)")
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUnitViewController",
           let destination = segue.destination as? GuestUnitViewController,
           let data = sender as? [Any],
           let exercise = data[0] as? Exercise,
           let sectionTitle = data[1] as? String {
            
            destination.exercise = exercise
            destination.sectionTitle = sectionTitle
        }
    }



}
