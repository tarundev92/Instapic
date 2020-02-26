//
//  UserPostCell.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 02/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
protocol UserPostCellDelegate {
    func userPostDetail(postDetails: [String:Any])
}

class UserPostCell: UICollectionViewCell {
    
    @IBOutlet weak var userPostImage: UIImageView!
    var postDocRef: String?
    var profileDocRef: String?
    var delegate: UserPostCellDelegate?
    
    var post: ModelUserPost? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
//        print("UserPostCell updateView")
//        if let photoUrlString = post?.photoUrl {
//            let photoUrl = URL(string: photoUrlString)
//            photo.sd_setImage(with: photoUrl)
//        }
        userPostImage.image = post?.postImage
        
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.photo_TouchUpInside))
        userPostImage.addGestureRecognizer(tapGestureForPhoto)
        userPostImage.isUserInteractionEnabled = true
        
    }
    @objc func photo_TouchUpInside() {
        
        
        if let postDocRef = post?.documentReference,
           let profileDocRef = post?.profileReference
        {
            delegate?.userPostDetail(postDetails: ["postDocRef": postDocRef, "profileDocRef": profileDocRef])
        }
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        userPostImage.image = nil
//    }
    
    
//    func fill(with userPost: ModelUserPost){
//        userPostImage.image = userPost.postImage
//        self.postDocRef = userPost.documentReference
//        self.profileDocRef = userPost.profileReference
//    }
    
}
