//
//  UserTableViewCell.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 16/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
    func userProfileDetails(userId: String)
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var delegate: UserTableViewCellDelegate?
    var user: ModelUser? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        nameLabel.text = user?.username
        if let imageUrlString = user?.imageURL {
            profileImage.image = common.getImageDtaFromURL(imageURL: imageUrlString)
        }
        
        
        if user!.isFollowing {
            configureUnFollowButton()
        } else {
            configureFollowButton()
        }
        
    }
    
    func configureFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        followButton.backgroundColor = UIColor(red: 69/255, green: 142/255, blue: 255/255, alpha: 1)
        followButton.setTitle("Follow", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    
    func configureUnFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        followButton.backgroundColor = UIColor.clear
        followButton.setTitle("Following", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
    @objc func followAction() {
        if user!.isFollowing == false {
            UserService.followUnfollowAction(isFollowing: true, uid: user!.userId)
            configureUnFollowButton()
            user!.isFollowing = true
        }
    }
    
    @objc func unFollowAction() {
        if user!.isFollowing == true {
            UserService.followUnfollowAction(isFollowing: false, uid: user!.userId)
            configureFollowButton()
            user!.isFollowing = false
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGesture)
        nameLabel.isUserInteractionEnabled = true
    }
    
    @objc func nameLabel_TouchUpInside() {
        if let id = user?.userId {
            delegate?.userProfileDetails(userId: id)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
