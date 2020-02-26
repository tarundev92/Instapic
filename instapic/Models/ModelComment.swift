//
//  ModelComment.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 09/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import Foundation
import FirebaseFirestore

//protocol DocumentSerializable {
//    init?(dictionary:[String:Any])
//}

let comments = Comments()

struct ModelComment{
    var commentDocRef:String
    var userId:String
    var username:String
    var userImageURL:String
    var comment:String
//    var createdAt:String
    var createdAt:Timestamp
    
    var dictionary:[String:Any]{
        return [
            comments.commentDocRefKey: commentDocRef,
            comments.userIdKey: userId,
            comments.userNameKey: username,
            comments.userImageURLKey: userImageURL,
            comments.commentKey: comment,
            comments.createdKey: createdAt
        ]
    }
}

extension ModelComment : DocumentSerializable {
    init?(dictionary: [String:Any]) {
//        print("dictionary\(dictionary)")
        guard let commentDocRef = dictionary[comments.commentDocRefKey] as? String else {
//            print("commentDocRef returning nil----------------")
            return nil}
        
        guard let userId = dictionary[comments.userIdKey] as? String else {
//            print("userId returning nil----------------")
            return nil}
        
        guard let username = dictionary[comments.userNameKey] as? String else {
//            print("username returning nil----------------")
            return nil}
        
        guard let userImageURL = dictionary[comments.userImageURLKey] as? String else {
//            print("userImageURL returning nil----------------")
            return nil}
        
        guard let comment = dictionary[comments.commentKey] as? String else {
//            print("comment returning nil----------------")
            return nil}
        
        guard let createdAt = dictionary[comments.createdKey] as? Timestamp else {
//            print("createdAt returning nil----------------")
            return nil}
        
//        guard let commentDocRef = dictionary[comments.commentDocRefKey] as? String,
//            let userId = dictionary[comments.userIdKey] as? String,
//            let username = dictionary[comments.userNameKey] as? String,
//            let userImageURL = dictionary[comments.userImageURLKey] as? String,
//            let comment = dictionary[comments.commentKey] as? String,
////            let createdAt = dictionary[comments.createdKey] as? String  else {
//            let createdAt = dictionary[comments.createdKey] as? Timestamp else {
//                print("ModelComment returning nil----------------")
//                return nil}
        
        self.init(commentDocRef: commentDocRef, userId: userId, username: username, userImageURL: userImageURL, comment: comment, createdAt: createdAt)
    }
}
