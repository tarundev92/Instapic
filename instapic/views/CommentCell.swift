//
//  CommentCell.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 09/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import KILabel

protocol CommentCellDelegate {
    func goToProfileUserVC(userId: String)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userProfilePic: UIImageView!
    
    @IBOutlet weak var commentLbl: KILabel!
    
    var delegate: CommentCellDelegate?
//    let common = Common()
    var comment: ModelComment?{
        didSet{
            self.updateUI()
        }
    }
    
    func updateUI(){
        userNameLbl.text = comment?.username
        self.userProfilePic.image = common.getImageDtaFromURL(imageURL: comment!.userImageURL)
        self.commentLbl.text = comment?.comment
        
//        commentLbl.userHandleLinkTapHandler = {
//            label, handle, rang in
//            var mention = handle
//            mention = String(mention.characters.dropFirst())
//            Api.User.observeUserByUsername(username: mention.lowercased(), completion: { (user) in
//                self.delegate?.goToProfileUserVC(userId: user.id!)
//            })
//
//        }

        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userNameLbl.text = ""
        commentLbl.text = ""
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.userNameLbl_TouchUpInside))
        userNameLbl.addGestureRecognizer(tapGestureForNameLabel)
        userNameLbl.isUserInteractionEnabled = true
    }
    
    @objc func userNameLbl_TouchUpInside() {
//        if let id = user?.id {
//            delegate?.goToProfileUserVC(userId: id)
//        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userProfilePic.image = UIImage(named: "placeholderImg")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
