//
//  ActivityService.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 19/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class ActivityService{
    static func addLikedActivity(curUserDocId: String, postUserDocId: String, postCaption: String){
        let db = Firestore.firestore()
        let batch  = db.batch()
        let curUserDocRef = db.document("\(userProfile.collectionName)/\(curUserDocId)")
        let postUserDocRef = db.document("\(userProfile.collectionName)/\(postUserDocId)")
//        print("---addLikedActivity curUserDocId:\(curUserDocId)")
//        print("---addLikedActivity postUserDocId:\(postUserDocId)")
//        print("---addLikedActivity postCaption:\(postCaption)")
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            //            let currentUserDoc: DocumentSnapshot
            do {
//                print("---addLikedActivity start trans")
                
                
                let curUserDoc = try transaction.getDocument(curUserDocRef)
                guard var curUserData = curUserDoc.data() else {
//                    print("-----addLikedActivity curUserData error")
                    return nil }
//                print("---addLikedActivity curUserDoc done")
//                print("---addLikedActivity read all done")
                
                
                var followers = curUserData[userProfile.followersKey] as? [String]
                if(followers == nil){
                    followers = []
                }
                let currUsername = curUserData[userProfile.usernameKey] as! String
                
                
                let postUserLikeMsg = "liked your post:\(postCaption)"
                
                var curUserLikeMsg = "liked his post:\(postCaption)"
                var postUserData:[String:Any] = [:]
                if curUserDocId != postUserDocId{
                    let postUserDoc = try transaction.getDocument(postUserDocRef)
                    guard let tpostUserData = postUserDoc.data() else {
//                        print("-----addLikedActivity postUserData error")
                        return nil }
                    postUserData = tpostUserData
                    let postUsername = postUserData[userProfile.usernameKey] as! String
                    curUserLikeMsg = "liked \(postUsername)'s post:\(postCaption)"
                    
                }
                
                let currUserActivityObj = [
                    activity.usernameKey: "You",
                    activity.activityMsgKey: curUserLikeMsg,
                    activity.userImageURLKey: curUserData[userProfile.picURLKey] as! String,
                    activity.isYouKey: true,
                    activity.createdKey: Date()
                    ] as [String:Any]
                
                let postUserActivityObj = [
                    activity.usernameKey: currUsername,
                    activity.activityMsgKey: postUserLikeMsg,
                    activity.userImageURLKey: curUserData[userProfile.picURLKey] as! String,
                    activity.isYouKey: true,
                    activity.createdKey: Date()
                    ] as [String:Any]
                
                let followersActivityObj = [
                    activity.usernameKey: currUsername,
                    activity.activityMsgKey: curUserLikeMsg,
                    activity.userImageURLKey: curUserData[userProfile.picURLKey] as! String,
                    activity.isYouKey: false,
                    activity.createdKey: Date()
                    ] as [String:Any]
//                print("---addLikedActivity activity msg cons all done")
                if curUserDocId != postUserDocId{
                    let currUserActivity = db.collection("\(userProfile.collectionName)/\(curUserDocId)/\(activity.collectionName)").document()
                    
                    batch.setData(currUserActivityObj, forDocument: currUserActivity)
                    
                    let postUserActivity = db.collection("\(userProfile.collectionName)/\(postUserDocId)/\(activity.collectionName)").document()
                    
                    batch.setData(postUserActivityObj, forDocument: postUserActivity)
                }
                
                for profileDocId in followers!{
                    
                    let followersActivity = db.collection("\(userProfile.collectionName)/\(profileDocId)/\(activity.collectionName)").document()
                    
                    batch.setData(followersActivityObj, forDocument: followersActivity)
                    
                }
//                print("---addLikedActivity followers batch all done")
                
                
                //                transaction.
                transaction.updateData(curUserData, forDocument: curUserDocRef)
                if curUserDocId != postUserDocId{
                    transaction.updateData(postUserData, forDocument: postUserDocRef)
                }
//                print("---addLikedActivity all done")
                return true
            } catch {
                // Error getting restaurant data
                // ...
            }
            
            return nil
        }) { (object, err) in
            if let err = err{
                print(err.localizedDescription)
            }else{
                batch.commit(completion: { (error) in
                    if let error = error {
                        print("\(error)")
                    } else {
                        print("batch write success")
                    }
                })
            }
        }
        
        
    }
    
    
    static func addFollowedActivity(curUserDocId: String, followedUserDocId: String){
        let db = Firestore.firestore()
        let batch  = db.batch()
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            //            let currentUserDoc: DocumentSnapshot
            do {
//                print("---addFollowedActivity runtransaction")
                let curUserDocRef = db.document("\(userProfile.collectionName)/\(curUserDocId)")
                
                let curUserDoc = try transaction.getDocument(curUserDocRef)
                guard var curUserData = curUserDoc.data() else {
//                    print("addLikedActivity curUserData error")
                    return nil }
                
                
                let followedUserDocRef = db.document("\(userProfile.collectionName)/\(followedUserDocId)")
                let followedUserDoc = try transaction.getDocument(followedUserDocRef)
                guard var followedUserData = followedUserDoc.data() else {
//                    print("addLikedActivity postUserData error")
                    return nil }
                
                
                
                
                var followers = curUserData[userProfile.followersKey] as? [String]
                if(followers == nil){
                    followers = []
                }
                let currUsername = curUserData[userProfile.usernameKey] as! String
                let followedUsername = followedUserData[userProfile.usernameKey] as! String
                let curUserFollowedMsg = "started following \(followedUsername)"
                
                let followedUserMsg = "started following you"
                
                
                let currUserActivityObj = [
                    activity.usernameKey: "You",
                    activity.activityMsgKey: curUserFollowedMsg,
                    activity.userImageURLKey: curUserData[userProfile.picURLKey] as! String,
                    activity.isYouKey: true,
                    activity.createdKey: Date()
                    ] as [String:Any]
                
                let followedUserActivityObj = [
                    activity.usernameKey: currUsername,
                    activity.activityMsgKey: followedUserMsg,
                    activity.userImageURLKey: curUserData[userProfile.picURLKey] as! String,
                    activity.isYouKey: true,
                    activity.createdKey: Date()
                    ] as [String:Any]
                
                let followersActivityObj = [
                    activity.usernameKey: currUsername,
                    activity.activityMsgKey: curUserFollowedMsg,
                    activity.userImageURLKey: curUserData[userProfile.picURLKey] as! String,
                    activity.isYouKey: false,
                    activity.createdKey: Date()
                    ] as [String:Any]
                
                let currUserActivity = db.collection("\(userProfile.collectionName)/\(curUserDocId)/\(activity.collectionName)").document()
                
                batch.setData(currUserActivityObj, forDocument: currUserActivity)
                
                let followedUserActivity = db.collection("\(userProfile.collectionName)/\(followedUserDocId)/\(activity.collectionName)").document()
                
                batch.setData(followedUserActivityObj, forDocument: followedUserActivity)
                
//                print("---followers list start")
                for userId in followers!{
                    //                    let followersBatch = db.batch()
                    let followersActivity = db.collection("\(userProfile.collectionName)/\(userId)/\(activity.collectionName)").document()
                    
                    batch.setData(followersActivityObj, forDocument: followersActivity)
                    //                    followersBatch.commit(completion: { (error) in
                    //                        if let error = error {
                    //                            print("\(error)")
                    //                        } else {
                    //                            print("followersBatch write success")
                    //                        }
                    //                    })
//                    print("---followers list inside")
                }
//                print("---followers list end")
                
                transaction.setData(curUserData, forDocument: curUserDocRef)
                transaction.setData(followedUserData, forDocument: followedUserDocRef)
//                print("---- trans write complete")
                
                //                return true
                
            } catch let fetchError as NSError {
                print("-------------fetchError: \(fetchError)")
                return nil
            }
            
            return nil
            
        }) { (object, err) in
            if let err = err{
                print("------------trans error:\(err.localizedDescription)")
            }else{
//                print("Transaction successfully committed!")
                batch.commit(completion: { (error) in
                    if let error = error {
                        print("\(error)")
                    } else {
                        print("--addFollowedActivity batch write success")
                    }
                })
                
            }
        }
        
        
    }
    
    
    
}
