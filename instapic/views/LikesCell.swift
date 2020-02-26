//
//  LikesCell.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 20/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit

protocol LikesCellDelegate {
    func goToProfileUserVC(userId: String)
}

class LikesCell: UITableViewCell {
    

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    var delegate: LikesCellDelegate?
    
    var likedUser: ModelUser?{
        didSet{
            self.updateUI()
        }
    }
    
    func updateUI(){
//        print("likecell updateUI")
        usernameLbl.text = likedUser?.username
        profileImageView.image = common.getImageDtaFromURL(imageURL: likedUser!.imageURL)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
