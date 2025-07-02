//
//  AchivementsCollectionViewCell.swift
//  islearn
//
//  Created by student-2 on 14/01/25.
//

import UIKit

class AchievementsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var MainTrophy: UIImageView!
    
    @IBOutlet weak var bronzeTrophy: UIImageView!
    
    @IBOutlet weak var silverTrophy: UIImageView!
    
    @IBOutlet weak var goldTrophy: UIImageView!
 
    @IBOutlet weak var achievementTitle: UILabel!
    
    @IBOutlet weak var achievementDetail: UILabel!
    
    @IBOutlet weak var achievementProgress: UIProgressView!
}
