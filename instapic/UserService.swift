//
//  UserService.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 16/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
class UserService{
    let db = Firestore.firestore()
    
    static func getSuggestUsers(completion: @escaping (ModelUser?) -> Void){
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.document("\(userProfile.collectionName)/Profile_\(userId)").getDocument(){
            document, error in
            if let error = error{
                print("Error:\(error.localizedDescription)")
                
            }else{
                var following:[String] = []
                if let temp = document?.data()?[userProfile.followingKey] as? [String]{
                    following = temp
                }
                var followers:[String] = []
                if let temp = document?.data()?[userProfile.followersKey] as? [String]{
                    followers = temp
                }
                let follwersIamNotFollowing = followers.filter(){!following.contains($0)}
                print("my following list:\(following)")
                let currentUserDocId = "\(document!.documentID)"
//                for profileId in following{
//                    db.document("\(userProfile.collectionName)/\(profileId)").get
//                }
                
                
                let USERS_REF_COLLECTION = db.collection(userProfile.collectionName)
                USERS_REF_COLLECTION.order(by: userProfile.followersCountKey, descending: true).getDocuments(){
                    querySnapshot, error in
                    if let error = error{
                        print("Error:\(error.localizedDescription)")
                        
                    }else{
//                        var queryData = [[String: Any]]()
                        var userCounter:Int = 0
                        for document in querySnapshot!.documents{
                            print("query doc: \(document.documentID)")
                            if(userCounter > 15){
                                break
                            }
                            if(currentUserDocId != "\(document.documentID)" && !following.contains("\(document.documentID)")){
                                
                                var tempUser = document.data()
                                tempUser[userProfile.uidKey] = "\(document.documentID)"
                                tempUser[userProfile.followingKey] = following
//                                queryData.append(tempUser)
                                userCounter = userCounter + 1
                                completion(ModelUser(dictionary: tempUser)!)
                            }
                        }
                        
                        let userProfileIdCount = follwersIamNotFollowing.count
                        var iterCount = 0
                        if(iterCount==userProfileIdCount){
                            completion(nil)
                        }
                        for userProfileId in follwersIamNotFollowing{
                            db.document("\(userProfile.collectionName)/\(userProfileId)").getDocument(){
                                document, error in
                                if let error = error{
                                    print("Error:\(error.localizedDescription)")
                                    
                                }else{
                                    iterCount = iterCount + 1
                                    if let userData = document!.data(){
                                    var tempUser = userData
                                    tempUser[userProfile.uidKey] = "\(document!.documentID)"
                                    tempUser[userProfile.followingKey] = following
//                                    queryData.append(tempUser)
                                    completion(ModelUser(dictionary: tempUser)!)
                                        if(iterCount==userProfileIdCount){
                                            completion(nil)
                                        }
                                    }
                                }
                            }
                        }
//                        let users = queryData.compactMap({ModelUser(dictionary: $0)})
//                        completion(users)
                        
                    }
                    
                    
                    
                }
                
            }
        }
    }
    
    static func getUsersByUsername(withText text: String, completion: @escaping ([ModelUser]) -> Void){
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.document("\(userProfile.collectionName)/Profile_\(userId)").getDocument(){
            document, error in
            if let error = error{
                print("Error:\(error.localizedDescription)")
                
            }else{
                var following:[String] = []
                if let temp = document?.data()?[userProfile.followingKey] as? [String]{
                    following = temp
                }
                let currentUserDocId = "\(document!.documentID)"
                let USERS_REF_COLLECTION = db.collection(userProfile.collectionName)
                USERS_REF_COLLECTION.whereField(userProfile.usernameKey, isGreaterThan: text).whereField(userProfile.usernameKey, isLessThan: text+"\u{f8ff}").limit(to: 10).getDocuments(){
                    querySnapshot, error in
                    if let error = error{
                        print("Error:\(error.localizedDescription)")
                        
                    }else{
                        var queryData = [[String: Any]]()
                        for document in querySnapshot!.documents{
                            if(currentUserDocId != "\(document.documentID)"){
                                var tempUser = document.data()
                                tempUser[userProfile.uidKey] = "\(document.documentID)"
                                tempUser[userProfile.followingKey] = following
                                queryData.append(tempUser)
                            }
                        }
                        let users = queryData.compactMap({ModelUser(dictionary: $0)})
                        completion(users)
                        
                    }
                    
                    
                    
                }
                
            }
        }
    }
    
    static func followUnfollowAction(isFollowing: Bool, uid: String){
        let db = Firestore.firestore()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let userId = "Profile_\(currentUid)"
        let profileRef: DocumentReference = db.document("\(userProfile.collectionName)/\(userId)")
        
        let followingProfileRef: DocumentReference = db.document("\(userProfile.collectionName)/\(uid)")

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let profileDocument: DocumentSnapshot
            let followingProfileDocument: DocumentSnapshot
            do {
                try profileDocument = transaction.getDocument(profileRef)
                guard var profileData = profileDocument.data() else { return nil }
//                print("profileData: \(profileData)")
                
                try followingProfileDocument = transaction.getDocument(followingProfileRef)
                
                guard var followingProfileData = followingProfileDocument.data() else { return nil }
                // Compute new number of likes
                var following = profileData[userProfile.followingKey] as? [String]
                var numFollowing = 0
                if let followingCount = profileData[userProfile.followingCountKey] as? Int{
                    numFollowing = followingCount
                }
                var newNumfollowing = numFollowing
                
                var followers = followingProfileData[userProfile.followersKey] as? [String]
                var numFollowers = 0
                if let followersCount = followingProfileData[userProfile.followersCountKey] as? Int{
                    numFollowers = followersCount
                }
                var newNumfollowers = numFollowers
                
                
                if(isFollowing){
                    if(following != nil ){
                        if(following!.contains(uid)){
                            newNumfollowing = numFollowing - 1
                            following = following!.filter(){$0 != uid}
                        }else{
                            following?.append(uid)
                            newNumfollowing = numFollowing + 1
                        }
                        
                    }else{
                        following = [uid]
                        newNumfollowing = numFollowing + 1
                    }
                    
                    if(followers != nil){
                        if(followers!.contains(userId)){
                            newNumfollowers = numFollowers - 1
                            followers = followers!.filter(){$0 != userId}
                        }else{
                            followers?.append(userId)
                            newNumfollowers = numFollowers + 1
                        }
                    }else{
                        followers = [userId]
                        newNumfollowers = numFollowers + 1
                        
                    }
                }
                
                if(!isFollowing){
                    if(following != nil ){
                        if(following!.contains(uid)){
                            newNumfollowing = numFollowing - 1
                            following = following!.filter(){$0 != uid}
                        }
                    }
                }
                
                if(!isFollowing){
                    if(followers != nil ){
                        if(followers!.contains(userId)){
                            newNumfollowers = numFollowers - 1
                            followers = followers!.filter(){$0 != userId}
                        }
                    }
                }
                
                
                
                
                
                // Set new likes info
                profileData[userProfile.followingKey] = following
                profileData[userProfile.followingCountKey] = newNumfollowing
                
                followingProfileData[userProfile.followersKey] = followers
                followingProfileData[userProfile.followersCountKey] = newNumfollowers
//                print(profileData)
//                print(followingProfileData)
                // Commit to Firestore
                transaction.setData(profileData, forDocument: profileRef)
                transaction.setData(followingProfileData, forDocument: followingProfileRef)
                
                
                
            } catch {
                print("errorPointer:\(errorPointer?.debugDescription)")
            }
            
            return nil
        }) { (object, err) in
            if let err = err{
                print("err:\(err.localizedDescription)")
            }else{
                if(isFollowing){
//                    print("----calling addFollowedActivity")
                    ActivityService.addFollowedActivity(curUserDocId: userId, followedUserDocId: uid)
                }
            }
        }
        
    }
    
    static func updatePostCount(isPostAdded: Bool){
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let profileRef: DocumentReference = db.document("\(userProfile.collectionName)/Profile_\(userId)")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let profileDocument = try transaction.getDocument(profileRef)
                guard var profileData = profileDocument.data() else { return nil }
                
                // Compute new number of likes
//                var followers = profileData[userProfile.followersKey] as? [String]
                var numPost = 0
                if let postCount = profileData[userProfile.postCountKey] as? Int{
                    numPost = postCount
                }
                var newNumPost = numPost

                
                if(isPostAdded){
                    newNumPost = numPost + 1
                }
                
                if(!isPostAdded){
                    newNumPost = numPost - 1
                }

                
                // Set new likes info
                profileData[userProfile.postCountKey] = newNumPost
//                print(profileData)
                // Commit to Firestore
                transaction.setData(profileData, forDocument: profileRef)

            } catch {
                // Error getting restaurant data
                // ...
            }
            
            return nil
        }) { (object, err) in
            if let err = err{
                print(err.localizedDescription)
            }
        }
        
        
    }
    
}
