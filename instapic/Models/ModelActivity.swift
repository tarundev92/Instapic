//
//  ModelActivity.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 19/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

struct ModelActivity{
    var username:String
    var userImageURL:String
    var activityMsg:String
    var createdAt:Timestamp
    
    var dictionary:[String:Any]{
        return [
            activity.usernameKey: username,
            activity.userImageURLKey: userImageURL,
            activity.activityMsgKey: activityMsg,
            activity.createdKey: createdAt
        ]
    }
    
}

extension ModelActivity : DocumentSerializable {
    init?(dictionary: [String:Any]) {
        guard let username = dictionary[activity.usernameKey] as? String else {
//            print("ModelActivity username returning nil----------------")
            return nil}
        guard let userImageURL = dictionary[activity.userImageURLKey] as? String else {
//            print("ModelActivity userImageURL returning nil----------------")
            return nil}
        guard let activityMsg = dictionary[activity.activityMsgKey] as? String else {
//            print("ModelActivity activityMsg returning nil----------------")
            return nil}
        guard let createdAt = dictionary[activity.createdKey] as? Timestamp else {
//            print("ModelActivity createdAt returning nil----------------")
            return nil}
        
        self.init(username: username, userImageURL: userImageURL, activityMsg: activityMsg, createdAt: createdAt)
        
    }
}
