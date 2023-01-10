//
//  MyCalendarTableViewCell.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/12/05.
//

import UIKit

class MyCalendarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var onlineFlagLabel: UILabel!
    @IBOutlet weak var castLabel: UILabel!
    @IBOutlet weak var eventStartLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventReferenceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
