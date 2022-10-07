//
//  FollowUserTableViewCell.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/10/07.
//

import UIKit

class FollowUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDisplayIdLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
