//
//  PostDetailViewController.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 09/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class PostDetailViewController: UIViewController {
    
    var userPostDetail: [String:Any]?
//    var postDetail: [String:String]?
    @IBOutlet weak var tableView: UITableView!
    var post = [ModelPost]()
//    var db:Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()

        
//        print("-------------------data received")

        // Do any additional setup after loading the view.
        loadPost()
    }
    
    
    func loadPost() {
        let db = Firestore.firestore()
        guard let postDetail = userPostDetail else { return }
//        print("\(postDetail)")
//        print("\(postDetail["postDocRef"]!)")
//        print("\(postDetail["profileDocRef"]!)")
        let activityIndicator = common.startLoader(onView: self.view)
        let postDocRef = db.document("\(postDetail["postDocRef"]!)")


//        print("postDocRef")
        postDocRef.getDocument(){
            (query, error) in
            
            
            if let error = error{
                print("Error:\(error.localizedDescription)")
            }else{
//                print("before guard")
                guard var postData = query?.data() else {return}
//                print("postData:\(postData)")
                self.fetchUser(profileDocRef: postDetail["profileDocRef"] as! String, completed: {userData in
                    
                    postData[posts.postDocRefKey] = postDetail["postDocRef"]!
                    postData[posts.userIdKey] = userData[userProfile.uidKey]
                    postData[posts.userNameKey] = userData[userProfile.usernameKey]
                    postData[posts.userImageURLKey] = userData[userProfile.picURLKey]
                    
                    self.post.append(ModelPost(dictionary: postData)!)
                    
                    
                    
                    self.tableView.reloadData()
                    common.stopLoader(activityIndicator: activityIndicator)
                })
                
                
            }
        }
//        print("loadpost end")

    }
    
    func fetchUser(profileDocRef: String, completed:  @escaping ([String:String]) -> Void ) {
        let db = Firestore.firestore()
        let profileDocRef = db.document(profileDocRef)
        profileDocRef.getDocument(){
            query, error in
            if let error = error{
                print("fetchUser error:\(error.localizedDescription)")
            }else{
//                print("fetchUser else")
                guard let profileData = query?.data() else {return}
//                print("profileData:\(profileData)")
                completed([userProfile.uidKey: profileData[userProfile.uidKey] as! String,userProfile.usernameKey: profileData[userProfile.usernameKey] as! String,
                           userProfile.picURLKey: profileData[userProfile.picURLKey] as! String])
                
                
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail_CommentVC" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender  as! String
            commentVC.postRef = postId
        }
        
        if segue.identifier == "Detail_LikeVC" {
            let likeVC = segue.destination as! LikesViewController
            let postRef = sender  as! String
            likeVC.postRef = postRef
        }
        
//        if segue.identifier == "Detail_ProfileUserSegue" {
//            let profileVC = segue.destination as! ProfileUserViewController
//            let userId = sender  as! String
//            profileVC.userId = userId
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PostDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        cell.post = post.first
//        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension PostDetailViewController: PostCellDelegate {
    func segueToCommentVC(postRef: String) {
        performSegue(withIdentifier: "Detail_CommentVC", sender: postRef)
    }
    func segueToLikeVC(postRef: String) {
        performSegue(withIdentifier: "Detail_LikeVC", sender: postRef)
    }
    func segueToProfileUserVC(userRef: String) {
        performSegue(withIdentifier: "Detail_ProfileUserSegue", sender: userRef)
    }
    
    func sharePost(post: ModelPost) {
//        if mcSession.connectedPeers.count>0{
//            //            let data:Data = post
//            let encoder = JSONEncoder()
//            do {
//                var postObj = post
//                postObj.isInRange = true
//                let data = try encoder.encode(postObj)
//                do {
//                    try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
//                }catch{
//                    fatalError("Could not send post")
//                }
//            }catch{
//                fatalError(error.localizedDescription)
//            }
//
//        }else{
//            let alert = UIAlertController(title: "Info", message: "Not connected to any host!", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
//        }
       
    }
    
}

