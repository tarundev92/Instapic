//
//  PostCell.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 01/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

protocol PostCellDelegate {
    func segueToCommentVC(postRef: String)
    func segueToLikeVC(postRef: String)
    func segueToProfileUserVC(userRef: String)
    func sharePost(post: ModelPost)
}

class PostCell: UITableViewCell {
    
    var delegate: PostCellDelegate!
    
    
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
//    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var captionLbl: UILabel!
    @IBOutlet weak var numberOfLikesBtn: UIButton!
    @IBOutlet weak var volumeBtn: UIButton!
    @IBOutlet weak var volumeImageView: UIView!
    @IBOutlet weak var heightConstraintPhoto: NSLayoutConstraint!

    @IBOutlet weak var inRangeBtn: UIButton!
    
    @IBOutlet weak var postTimeLbl: UILabel!
    let borderLike = UIImage(named: "icon-like")
    let filledLike = UIImage(named: "likeSelected")
    var isMuted = true
//
//    @IBOutlet weak var profilePicView: UIImageView!
//    @IBOutlet weak var usernameLbl: UILabel!
//
//    @IBOutlet weak var postImageView: UIImageView!
//    @IBOutlet weak var numberOfLikesBtn: UIButton!
//    @IBOutlet weak var captionLbl: UILabel!
//    @IBOutlet weak var heightConstraintPhoto: NSLayoutConstraint!
//
//
//    @IBOutlet weak var volumeButton: UIButton!
//    @IBOutlet weak var volumeImageView: UIView!

    
    
    let common = Common()
    var post: ModelPost!{
//    var post: TempPost!{
        didSet{
            self.updateUI()
        }
    }
    
    func updateUI(){
        inRangeBtn.layer.borderWidth = 1.0
        inRangeBtn.layer.cornerRadius = 2.0
        inRangeBtn.layer.borderColor = inRangeBtn.tintColor.cgColor
        inRangeBtn.layer.masksToBounds = true
        
        
        guard post != nil else {return}
        postImageView.image = self.common.getImageDtaFromURL(imageURL: post.imageURL)
//        if let ratio = post?.ratio {
//            heightConstraintPhoto.constant = UIScreen.main.bounds.width / ratio
//            layoutIfNeeded()
//
//        }
        
        captionLbl.text = post.caption
        usernameLbl.text = post.username
        profilePicView.image = common.getImageDtaFromURL(imageURL: post.userImageURL)
        postTimeLbl.text = common.timeAgoSince(dateTimestamp: post.createdAt)
//        print("------------------------post.createdAt: \(post.createdAt)")
        
       inRangeBtn.isHidden = !post.isInRange
        
        updateLike()
//        numberOfLikesBtn.setTitle("Be the first to one like", for: [])
        
        
    }
    
    func updateLike() {
        
        let imageName = self.post.likes == nil || !self.post.isLiked ? "icon-like" : "likeSelected"
        
//        self.likeBtn.setBackgroundImage(UIImage(named: imageName), for: UIControlState.normal)
        
        likeImageView.image = UIImage(named: imageName)
        
        let count = self.post.likeCount
        if count != 0 {
            self.numberOfLikesBtn.setTitle("\(count) likes", for: UIControlState.normal)
        } else {
            self.numberOfLikesBtn.setTitle("Be the first to like this", for: UIControlState.normal)
        }
        
    }
    
//    func setupUserInfo() {
//        usernameLbl.text = user?.username
//        if let photoUrlString = user?.profileImageUrl {
//            let photoUrl = URL(string: photoUrlString)
//            profilePicView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
//
//        }
//    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        usernameLbl.text = ""
        captionLbl.text = ""
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TouchUpInside))
        commentImageView.addGestureRecognizer(tapGesture)
        commentImageView.isUserInteractionEnabled = true
        
        let tapGestureForShareImageView = UITapGestureRecognizer(target: self, action: #selector(self.shareImageView_TouchUpInside))
        shareImageView.addGestureRecognizer(tapGestureForShareImageView)
        shareImageView.isUserInteractionEnabled = true
        
        let tapGestureForLikeImageView = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_TouchUpInside))
        likeImageView.addGestureRecognizer(tapGestureForLikeImageView)
        likeImageView.isUserInteractionEnabled = true
        
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.usernameLabel_TouchUpInside))
        usernameLbl.addGestureRecognizer(tapGestureForNameLabel)
        usernameLbl.isUserInteractionEnabled = true
    }
    
    @objc func usernameLabel_TouchUpInside() {
//        if let id = user?.id {
//            delegate?.segueToProfileUserVC(userId: id)
//        }
    }
    
    @objc func likeImageView_TouchUpInside() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        //        let activityIndicator = common.startLoader(onView: self.view)
        PostService.likeUpdate(postRefString: post.postDocRef, uid: userId, onSuccess: {(postData) in
            
            self.post?.likes = postData[posts.likesKey] as? [String]
            self.post?.isLiked = postData["isLiked"] as! Bool
            self.post?.likeCount = postData[posts.likeCountKey] as! Int
//            self.updateLike()
//            print("update done")
            //            self.common.stopLoader(activityIndicator: activityIndicator)
            
        }) {(errorMessage) in
            let alert = UIAlertController(title: "Info", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            //            self.present(alert, animated: true)
            
        }
    }
    
//    @IBAction func likeBtnAction(_ sender: Any) {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//        //        let activityIndicator = common.startLoader(onView: self.view)
//        PostService.likeUpdate(postRefString: post.postDocRef, uid: userId, onSuccess: {(postData) in
//
//            self.post?.likes = postData.likes
//            self.post?.isLiked = postData.isLiked
//            self.post?.likeCount = postData.likeCount
//            self.updateLike()
//            print("update done")
//            //            self.common.stopLoader(activityIndicator: activityIndicator)
//
//        }) {(errorMessage) in
//            let alert = UIAlertController(title: "Info", message: errorMessage, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
//            //            self.present(alert, animated: true)
//
//        }
//    }
    
    
    @objc func commentImageView_TouchUpInside() {
//        print("commentImageView_TouchUpInside")
//        print("-------------post:\(post)")
//        print("-------------post:\(post.postDocRef)")
        delegate?.segueToCommentVC(postRef: post.postDocRef)
        
    }
    
    @objc func shareImageView_TouchUpInside() {
        
        delegate?.sharePost(post: post)
        
    }
    
    @IBAction func likesBtnAction(_ sender: Any) {
        if((self.post?.likeCount)! > 0){
//            print("likesBtnAction postDocRef: \(post.postDocRef)")
        delegate?.segueToLikeVC(postRef: post.postDocRef)
        }
    }
    
//    @IBAction func commentsBtn(_ sender: Any) {
//
////        if(self.delegate != nil){ //Just to be safe.
////            self.delegate.callSegueFromCell(postId: self.post.postDocRef)
////        }
////
//
//    }
    
    @IBAction func volumeBtn_TouchUpInSide(_ sender: UIButton) {
        if isMuted {
            isMuted = !isMuted
            volumeBtn.setImage(UIImage(named: "Icon_Volume"), for: UIControlState.normal)
        } else {
            isMuted = !isMuted
            volumeBtn.setImage(UIImage(named: "Icon_Mute"), for: UIControlState.normal)
            
        }
//        player?.isMuted = isMuted
    }
    
}
