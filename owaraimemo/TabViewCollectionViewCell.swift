//
//  TabViewCollectionViewCell.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/09/07.
//

import UIKit

class TabViewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var comedianImageView: UIImageView!
    @IBOutlet weak var blankLabel: UILabel!
    @IBOutlet weak var comedianNameLabel: UILabel!
    
    @IBOutlet weak var comedianImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var blankLabelWidth: NSLayoutConstraint!
    
    var firstTabVC = FirstTabViewController()
    var cellSize: CGFloat = 0.0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        print("height:\(self.frame.height)")
//        self.cellSize = firstTabVC.cellSize
//        print("cellsize\(cellSize)")
        
        print("スクリーンサイズ:\(UIScreen.main.nativeBounds.height)")
        
        
        if UIScreen.main.nativeBounds.height <= 1334 {
            
            self.comedianImageViewHeight.constant = CGFloat(self.frame.height*0.8)
            self.blankLabelWidth.constant = CGFloat(self.frame.width*0.03)

            
        } else if UIScreen.main.nativeBounds.height <= 2208 {
            
            self.comedianImageViewHeight.constant = CGFloat(self.frame.height*0.9)
            self.blankLabelWidth.constant = CGFloat(self.frame.width*0.03)

            
        } else if UIScreen.main.nativeBounds.height <= 2436 {
            
            self.comedianImageViewHeight.constant = CGFloat(self.frame.height*0.8)
            self.blankLabelWidth.constant = CGFloat(self.frame.width*0.05)
            
        } else if UIScreen.main.nativeBounds.height <= 2532 {
            
            self.comedianImageViewHeight.constant = CGFloat(self.frame.height*0.9)
            self.blankLabelWidth.constant = CGFloat(self.frame.width*0.09)
            
        } else {
            
            self.comedianImageViewHeight.constant = CGFloat(self.frame.height*0.93)
            self.blankLabelWidth.constant = CGFloat(self.frame.width*0.05)
            
        }
        
        
//        self.blankLabelWidth.constant = CGFloat(self.frame.width*0.09)
        
    
        
        
    }

}
