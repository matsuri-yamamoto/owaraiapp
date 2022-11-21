//
//  TabViewCollectionViewCell.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/09/07.
//

import UIKit

class TabViewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var comedianImageView: UIImageView!
    @IBOutlet weak var referenceButton: UIButton!
    @IBOutlet weak var blankLabel: UILabel!
    @IBOutlet weak var comedianNameLabel: UILabel!
//    @IBOutlet weak var comedianImageViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var blankLabelWidth: NSLayoutConstraint!
    
    var cellSize: CGFloat = 0.0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

}
