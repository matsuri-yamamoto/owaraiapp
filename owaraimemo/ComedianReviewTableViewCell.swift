//
//  ComedianReviewTableViewCell.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/07/15.
//

import UIKit

class ComedianReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: CircleImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var scoreImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    var comedianDetailVC = ComedianDetailViewController()
    
    
    //備忘：制約をつけるときに、セルの高さを動的にする→https://qiita.com/y-okudera/items/f511dbe2b720931ee842
    
    

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButton(_ sender: Any) {

        let likeImage = UIImage(systemName: "heart")
        let unLikeImage = UIImage(systemName: "heart.fill")


        if likeButton.imageView?.image == likeImage {

            likeButton.setImage(unLikeImage, for: .normal)

        }

        if likeButton.imageView?.image == unLikeImage {

            likeButton.setImage(likeImage, for: .normal)
        }

        comedianDetailVC.tappedLikeButton()

    }
    
}

