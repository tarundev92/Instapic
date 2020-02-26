//
//  PicCollectionViewCell.swift
//  instapic
//
//  Created by Logesh Chinsu Palani on 16/10/18.
//  Copyright © 2018 Logesh Chinsu Palani. All rights reserved.
//

import UIKit

protocol PicCollectionViewCellDelegate {
    func postDetailSegue(postDetails: [String:Any])
}

class PicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var postPic: UIImageView!
    var delegate: PicCollectionViewCellDelegate?
    
    var post: ModelUserPost? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let postImage = post?.postImage {
            postPic.image = postImage
        }
        
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.pic_TouchUpInside))
        postPic.addGestureRecognizer(tapGestureForPhoto)
        postPic.isUserInteractionEnabled = true
        
    }
    
    @objc func pic_TouchUpInside() {
        if let postDocRef = post?.documentReference,
            let profileDocRef = post?.profileReference{
            delegate?.postDetailSegue(postDetails: ["postDocRef": postDocRef, "profileDocRef": profileDocRef])
        }
    }
    
}
