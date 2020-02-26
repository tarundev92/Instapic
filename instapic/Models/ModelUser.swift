//
//  ModelUser.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 16/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase


struct ModelUser{
    var userId: String
    var username:String
    var imageURL:String
    var isFollowing: Bool
    var postCount:Int
    var followersCount:Int
    var followingCount:Int
    
    var dictionary:[String:Any]{
        return [
            userProfile.uidKey: userId,
            userProfile.usernameKey: username,
            userProfile.picURLKey: imageURL,
            userProfile.postCountKey: postCount,
            userProfile.followersCountKey: followersCount,
            userProfile.followingCountKey: followingCount
        ]
    }
    
}

extension ModelUser : DocumentSerializable {
    init?(dictionary: [String:Any]) {
        guard let userId = dictionary[userProfile.uidKey] as? String,
            let username = dictionary[userProfile.usernameKey] as? String,
            let imageURL = dictionary[userProfile.picURLKey] as? String else {
//                print("ModelUser returning nil----------------")
                return nil}
        
        
        var isFollowing = false
        let following = dictionary[userProfile.followingKey] as? [String]
        if following != nil{
                isFollowing = following!.contains(userId)
            }
        
        var postCount = 0
        var followersCount = 0
        var followingCount = 0
        if let tempfollowersCount = dictionary[userProfile.followersCountKey] as? Int{
            followersCount = tempfollowersCount
        }
        if let tempfollowingCount = dictionary[userProfile.followingCountKey] as? Int{
            followingCount = tempfollowingCount
        }
        if let tempPostCount = dictionary[userProfile.postCountKey] as? Int{
            postCount = tempPostCount
        }
        
        self.init(userId: userId, username: username, imageURL: imageURL, isFollowing: isFollowing, postCount: postCount, followersCount: followersCount, followingCount: followingCount)
        
        
        
    }
}
