//
//  ModelPost.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 30/09/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

protocol DocumentSerializable {
    init?(dictionary:[String:Any])
}

protocol Serializable : Codable{
        func serialize() -> Data?
}


let posts = Posts()

struct ModelPost : Codable{
    var postDocRef:String
    var userId:String
    var username:String
    var userImageURL:String
    var caption:String
    var imageURL:String
    var videoURL:String?
    var likeCount: Int
    var likes: [String]?
    var isLiked: Bool
    var isInRange: Bool
    var createdAt:Double
    
    var dictionary:[String:Any]{
        return [
            posts.userIdKey: userId,
            posts.userNameKey: username,
            posts.userImageURLKey: userImageURL,
            posts.postDocRefKey: postDocRef,
            posts.captionKey: caption,
            posts.imageURLKey: imageURL,
            posts.videoURLKey: videoURL as Any,
            posts.likesKey: likes as Any,
            posts.createdKey: createdAt
            
        ]
    }
    
}

extension ModelPost : DocumentSerializable {
    init?(dictionary: [String:Any]) {
//        print("dictionary:\(dictionary)")
        guard let postDocRef = dictionary[posts.postDocRefKey] as? String else {
//            print("ModelPost postDocRef returning nil----------------")
            return nil}
        guard let userId = dictionary[posts.userIdKey] as? String else {
//            print("ModelPost userId returning nil----------------")
            return nil}
        guard let username = dictionary[posts.userNameKey] as? String else {
//            print("ModelPost username returning nil----------------")
            return nil}
        guard let userImageURL = dictionary[posts.userImageURLKey] as? String else {
//            print("ModelPost userImageURL returning nil----------------")
            return nil}
        guard let caption = dictionary[posts.captionKey] as? String else {
//            print("ModelPost caption returning nil----------------")
            return nil}
        guard let imageURL = dictionary[posts.imageURLKey] as? String else {
//            print("ModelPost imageURL returning nil----------------")
            return nil}
           guard let createdAtTimestamp = dictionary[posts.createdKey] as? Timestamp else {
//                print("ModelPost createdAt returning nil----------------")
                return nil}
        
        let createdAt = TimeInterval(createdAtTimestamp.seconds)
        
        let isInRange = false
        
        let likes = dictionary[posts.likesKey] as? [String]
        var videoURL: String?
        if let tempVideoURL = dictionary[posts.videoURLKey] {
            videoURL = tempVideoURL as? String
        }
        var likeCount = 0
        var isLiked = false
        if let currentUserId = Auth.auth().currentUser?.uid{
            if likes != nil{
                isLiked = likes!.contains("Profile_\(currentUserId)")
                likeCount = likes!.count
            }
        }
        
//        self.init(postDocRef: postDocRef, caption: caption, imageURL: imageURL, videoURL: videoURL, likeCount: likeCount, likes: likes, isLiked: isLiked, createdAt: createdAt)
        
        self.init(postDocRef: postDocRef, userId: userId, username: username, userImageURL: userImageURL, caption: caption, imageURL: imageURL, videoURL: videoURL, likeCount: likeCount, likes: likes, isLiked: isLiked, isInRange: isInRange, createdAt: createdAt)
 
    }
    

}

extension Serializable{
    func serialize() -> Data{
        let encoder = JSONEncoder()
        return try! encoder.encode(self)
    }
}
