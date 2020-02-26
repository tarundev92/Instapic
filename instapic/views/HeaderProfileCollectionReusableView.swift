//
//  HeaderProfileCollectionReusableView.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 16/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

protocol HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: ModelUser)
}

protocol HeaderProfileCollectionReusableViewDelegateEditProfile {
    func editProfileSegue()
}

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myPostsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    var delegate2: HeaderProfileCollectionReusableViewDelegateEditProfile?
    var user: ModelUser? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
    }
    
    func updateView() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        self.nameLabel.text = user!.username
        if let picURL = user?.imageURL {
            self.profileImage.image = common.getImageDtaFromURL(imageURL: picURL)
        }
//        if let imageUrlString = user?.imageURL {
//            self.profileImage.image = common.getImageDtaFromURL(imageURL: imageUrlString)
//        }
        
        self.myPostsCountLabel.text = "\(user!.postCount)"
        self.followingCountLabel.text = "\(user!.followingCount)"
        self.followersCountLabel.text = "\(user!.followersCount)"
        
        if user?.userId == "Profile_\(currentUserId)" {
            followButton.setTitle("Edit Profile", for: UIControlState.normal)
            followButton.addTarget(self, action: #selector(self.editProfileSegue), for: UIControlEvents.touchUpInside)

        } else {
            updateStateFollowButton()
        }


        
    }
    
    func clear() {
        self.nameLabel.text = ""
        self.myPostsCountLabel.text = ""
        self.followersCountLabel.text = ""
        self.followingCountLabel.text = ""
    }
    
    @objc func editProfileSegue() {
        delegate2?.editProfileSegue()
    }
    
    func updateStateFollowButton() {
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
//            Api.Follow.followAction(withUser: user!.id!)
            configureUnFollowButton()
            user!.isFollowing = true
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
    @objc func unFollowAction() {
        if user!.isFollowing == true {
//            Api.Follow.unFollowAction(withUser: user!.id!)
            configureFollowButton()
            user!.isFollowing = false
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
}
