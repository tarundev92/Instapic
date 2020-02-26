//
//  LikesViewController.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 20/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class LikesViewController: UIViewController {
    
    var db:Firestore!
    var likesPostCollectionRef:DocumentReference!
    var postRef: String?
    
    @IBOutlet weak var likesTableView: UITableView!
    var likedUsers = [ModelUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
//        print("--self.postRef:\(self.postRef!)")
        likesPostCollectionRef = db.document("\(self.postRef!)")
        
        title = "Likes"
        likesTableView.dataSource = self
        likesTableView.estimatedRowHeight = 68
        likesTableView.rowHeight = UITableViewAutomaticDimension
        loadLikedUsers()
    }
    
    func loadLikedUsers() {
        let activityIndicator = common.startLoader(onView: self.view)
        likesPostCollectionRef.getDocument(){
            querySnapshot, error in
            if let error = error{
                print("Error:\(error.localizedDescription)")
                common.stopLoader(activityIndicator: activityIndicator)
            }else{
                //                var queryData = [[String: Any]]()
                
                var postData:[String:Any] = [:]
                if let tpostData = querySnapshot!.data(){
                    postData = tpostData
                }
                
                var likedUsers:[String] = []
                if let tLikedUsers = postData[posts.likesKey] as? [String]{
                    likedUsers = tLikedUsers
                }
                
                for userProfileId in likedUsers{
                    let profileRefString = "\(userProfile.collectionName)/\(userProfileId)"
//                    print("--likes profileRefString: \(profileRefString)")
                    self.fetchUser(profileRefString: profileRefString, completed: {
                        userData in
                        
                        
                        self.likedUsers.append(ModelUser(dictionary: userData)!)
                        common.stopLoader(activityIndicator: activityIndicator)
                        self.likesTableView.reloadData()
                    })
                    
                    
                    
                }
                
                
            }
        }
    }
    
    func fetchUser(profileRefString: String, completed:  @escaping ([String:Any]) -> Void ) {
        var userData:[String:Any] = [:]
        self.db.document("\(profileRefString)").getDocument(){
            profileDocument, error in
            if let error = error{
                print("Error:\(error.localizedDescription)")
                
            }else{
                userData[userProfile.uidKey] = profileDocument!.data()![userProfile.uidKey]
                userData[userProfile.usernameKey] = profileDocument!.data()![userProfile.usernameKey]
                userData[userProfile.picURLKey] = profileDocument?.data()![userProfile.picURLKey]
                
                completed(userData)
                
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        if segue.identifier == "Comment_ProfileSegue" {
        //            let profileVC = segue.destination as! ProfileUserViewController
        //            let userId = sender  as! String
        //            profileVC.userId = userId
        //        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension LikesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikesCell", for: indexPath) as! LikesCell
        let likedUser = likedUsers[indexPath.row]
        //        let user = users[indexPath.row]
        cell.likedUser = likedUser
        //        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension LikesViewController: LikesCellDelegate {
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Likes_ProfileSegue", sender: userId)
    }
}
