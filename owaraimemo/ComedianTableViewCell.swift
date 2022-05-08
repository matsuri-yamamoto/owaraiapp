//
//  ComedianTableViewCell.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/04/04.
//

import UIKit
import Firebase

class ComedianTableViewCell: UITableViewCell {
    
    @IBOutlet weak var comedianNameLabel: UILabel!

    var comedianArray: [ComedianData] = []
    var comedianUniqueArray: [ComedianData] = []
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setComedianData(_ comedianData: ComedianData) {
        self.comedianNameLabel.text = comedianData.comedianName
        
    
    }
}
