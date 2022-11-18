//
//  ComedianReviewTableViewCell.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/07/15.
//

import UIKit
import FirebaseFirestore
import Firebase

class ComedianReviewTableViewCell: UITableViewCell {
    
//    @IBOutlet weak var userImageView: CircleImageView!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var scoreImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var continuationLabel: UILabel!
    @IBOutlet weak var alertButton: UIButton!
    
    var comedianDetailVC = ComedianDetailViewController()
    
    
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    
    //備忘：制約をつけるときに、セルの高さを動的にする→https://qiita.com/y-okudera/items/f511dbe2b720931ee842
    
    

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
    
}
    
