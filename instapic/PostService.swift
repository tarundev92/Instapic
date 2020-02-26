//
//  PostService.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 16/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
class PostService{
    
    static func getTopUserPosts(completion: @escaping (ModelUserPost?) -> Void){
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
//                print("my following list:\(following)")
                let currentUserDocId = "\(document!.documentID)"
                let USERS_REF_COLLECTION = db.collection(userProfile.collectionName)
                USERS_REF_COLLECTION.order(by: userProfile.followersCountKey, descending: true).getDocuments(){
                    querySnapshot, error in
                    if let error = error{
                        print("Error:\(error.localizedDescription)")
                        
                    }else{
                        //                        var queryData = [[String: Any]]()
                        var postCounter:Int = 0
                        for document in querySnapshot!.documents{
//                            print("query doc: \(document.documentID)")
                            if(postCounter > 20){
                                break
                            }
                            let userProfileId = document.documentID
                            if(currentUserDocId != "\(userProfileId)" && !following.contains("\(userProfileId)")){
                                //                                var userData = document.data()
                                db.collection("\(userProfile.collectionName)/\(userProfileId)/\(posts.collectionName)").order(by: posts.likeCountKey, descending: true).limit(to: 3).getDocuments(){
                                    querySnapshot, error in
                                    if let error = error{
                                        print("Error:\(error.localizedDescription)")
                                        
                                    }else{
                                        //                                        var queryData = [[String: Any]]()
                                        
                                        for document in querySnapshot!.documents{
                                            
                                            var tempPost = document.data()
                                            
                                            let docRef = "\(userProfile.collectionName)/\(userProfileId)/\(posts.collectionName)"
                                            let topPost = ModelUserPost(postImage: common.getImageDtaFromURL(imageURL: tempPost[posts.imageURLKey] as! String), documentReference: "\(docRef)/\(document.documentID)",
                                                profileReference: "\(userProfile.collectionName)/\(userProfileId)")
                                            
                                            postCounter = postCounter + 1
                                            completion(topPost)
                                            
                                        }
                                        
                                        completion(nil)
                                        
                                        
                                        
                                        
                                        
                                    }
                                    
                                }
                                
                                
                                //                                var tempUser = document.data()
                                //                                tempUser[userProfile.uidKey] = "\(document.documentID)"
                                //                                tempUser[userProfile.followingKey] = following
                                //                                queryData.append(tempUser)
                                //                                postCounter = postCounter + 1
                                
                            }
                        }
                        
                        
                    }
                    
                    
                    
                }
                
            }
        }
        
    }
    
    static func likeUpdate(postRefString: String, uid: String, onSuccess: @escaping ([String:Any]) -> Void, onError: @escaping (_ errorMessage: String?) -> Void){
        let db = Firestore.firestore()
        //        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userDocId = "Profile_\(uid)"
        let postRef: DocumentReference = db.document(postRefString)
        let currentUserDocPath:String = "\(userProfile.collectionName)/\(userDocId)"
        //        print("--likeUpdate postRefString: \(postRefString)")
        //        print("--likeUpdate uid: \(uid)")
        //        print("--likeUpdate userDocId: \(userDocId)")
        //        print("--likeUpdate currentUserDocPath: \(currentUserDocPath)")
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            //            let currentUserDoc: DocumentSnapshot
            do {
                let postDocument = try transaction.getDocument(postRef)
                guard var postData = postDocument.data() else { return nil }
                
                //                try currentUserDoc = transaction.getDocument(currentUserDocRef)
                //                guard var currentUserData = currentUserDoc.data() else { return nil }
                
                
                
                
                
                // Compute new number of likes
                var likes = postData[posts.likesKey] as? [String]
                var numLikes = 0
                if let likeCount = postData[posts.likeCountKey] as? Int{
                    numLikes = likeCount
                }
                var newNumLikes = numLikes + 1
                var isLiked = true
                if(likes != nil ){
                    if(likes!.contains(userDocId)){
                        newNumLikes = numLikes - 1
                        isLiked = false
                        likes = likes!.filter(){$0 != userDocId}
                    }else{
                        likes?.insert(userDocId, at: 0)
                    }
                }else{
                    likes = [userDocId]
                }
                
                
                // Set new likes info
                postData[posts.likesKey] = likes
                postData[posts.likeCountKey] = newNumLikes
                
                // Commit to Firestore
                transaction.updateData(postData, forDocument: postRef)
                var successPostData = postData
                //                successPostData[posts.userIdKey] = userDocId
                successPostData["isLiked"] = isLiked
                //                successPostData[posts.postDocRefKey] = "\(userProfile.collectionName)/\(userDocId)/\(posts.collectionName)/\(postDocument.documentID)"
                
                //                let mPost = ModelPost(dictionary: successPostData)!
//                print("--likeUpdate writing done. calling ActivityService.addLikedActivity ")
                if(isLiked){
                    ActivityService.addLikedActivity(curUserDocId: userDocId, postUserDocId: String(postRefString.split(separator: "/")[1]), postCaption: postData[posts.captionKey] as! String)
                }
//                print("--likeUpdate ActivityService.addLikedActivity done")
                onSuccess(successPostData)
                return successPostData
            } catch {
                // Error getting restaurant data
                // ...
            }
            
            return nil
        }) { (object, err) in
            if let err = err{
                onError(err.localizedDescription)
            }
        }
        
    }
    
}
