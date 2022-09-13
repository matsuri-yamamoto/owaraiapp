


import UIKit
class CircleImageView: UIImageView {
    @IBInspectable var borderColor :  UIColor = UIColor.systemGray3
    @IBInspectable var borderWidth :  CGFloat = 0.1

    override var image: UIImage? {
        didSet{
            layer.masksToBounds = false
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
            layer.cornerRadius = frame.height/2
            clipsToBounds = true
        }
    }
}
