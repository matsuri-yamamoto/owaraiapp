//
//  MyReviewTableViewCell.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/04.
//

import UIKit

class MyReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var comedianNameButton: UIButton!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreImageView: UIImageView!
    @IBOutlet weak var referenceButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var comedianImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    
//    @IBOutlet weak var beforeRelationalLabel: UILabel!
//    @IBOutlet weak var relationalComedianLabel: UILabel!
//    @IBOutlet weak var afterRelationalLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
