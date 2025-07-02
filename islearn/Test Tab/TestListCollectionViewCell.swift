import UIKit

protocol TestListCollectionViewCellDelegate : AnyObject {
    func testStart(testID : Int, buttonNumber : Int)
}

class TestListCollectionViewCell: UICollectionViewCell {
    weak var delegate : TestListCollectionViewCellDelegate?
    
    @IBOutlet weak var testNameLabel: UILabel!
    
    @IBOutlet weak var testDescriptionLabel: UILabel!
    
    @IBOutlet weak var testProgress: UILabel!
    
    @IBOutlet weak var progressBarView: UIView!
    
    @IBOutlet weak var newTestLabel: UILabel!
    
    @IBOutlet weak var testButton: UIButton!
    
    var testID : Int = 0
    
    @IBOutlet weak var ComingSoonLabel: UILabel!
    
    @IBAction func testStartButtonPressed(_ sender: UIButton) {
        delegate?.testStart(testID: testID, buttonNumber: testButton.tag)
    }
}
