//
//  HomeTableViewController.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 01/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

//protocol PostCellDelegator {
//    func callSegueFromCell(postId: String)
//}

class HomeTableViewController: UITableViewController {

    var db:Firestore!
    let userProfile = UserProfile()
    let common = Common()
    let posts = Posts()
    var postList = [ModelPost]()

//    var postList = [TempPost]()
    
    
    struct StoryBoard {
        static let postCell = "PostCell"
        static let postHeaderCell = "PostHeaderCell"
        static let postHeaderHeight: CGFloat = 57.0
        static let postCellDefaultHeight:CGFloat = 578.0
//        static let postCellDefaultHeight:CGFloat = 635.0
    }
    
//    @IBOutlet weak var postsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
//        self.tableView.dataSource = self
        loadPosts()
        checkPostsUpdate()
        
//        self.fetchPosts()
        
        tableView.estimatedRowHeight = StoryBoard.postCellDefaultHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor.clear
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadPosts(){
//        print("---------------load post")
        guard let uid = Auth.auth().currentUser?.uid else { return }

//        print("\(userProfile.collectionName) > Profile_\(uid) > \(posts.collectionName)")

        db.collection(userProfile.collectionName).document("Profile_\(uid)").collection(posts.collectionName).getDocuments(){
            querySnapshot, error in
            if let error = error{
                print("Error:\(error.localizedDescription)")
            }else{
//                print(querySnapshot!.documents[3].data())
                var queryData = [[String: Any]]()
                for document in querySnapshot!.documents{
//                    print(document)
//                    print(document.documentID)
                    var tempPost = document.data()
                    tempPost[self.posts.postDocRefKey] = "\(self.userProfile.collectionName)/Profile_\(uid)/\(self.posts.collectionName)/\(document.documentID)"
                    queryData.append(tempPost)

                }
//                print("------ALL DOC:\(queryData)")
                
                //                self.postList = querySnapshot!.documents.compactMap({ModelPost(dictionary: $0.data())})
                self.postList = queryData.compactMap({ModelPost(dictionary: $0)})
//                print("---------------------postList:")
//                print(self.postList)
                self.tableView.reloadData()
                //                DispatchQueue.main.async {
                //                    self.tableView.reloadData()
                //                }
            }
        }
    }

    func checkPostsUpdate(){
//        print("--------------- checkPostsUpdate")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var postsRef = db.collection(userProfile.collectionName).document("Profile_\(uid)").collection(posts.collectionName)

        postsRef.whereField(posts.createdKey, isGreaterThan: Date()).addSnapshotListener {querySnapshot, error in
            guard let snapshot = querySnapshot else {return}
//            print("--------------------update postList:")
//            print(snapshot.documents)
            snapshot.documentChanges.forEach {
                diff in
//                print(diff.document.data())
//                print(ModelPost(dictionary: diff.document.data())!)
                if diff.type == .added{
                    var tempPost = diff.document.data()
                    tempPost[self.posts.postDocRefKey] = "\(self.userProfile.collectionName)/Profile_\(uid)/\(self.posts.collectionName)/\(diff.document.documentID)"
                    self.postList.insert(ModelPost(dictionary: tempPost)!, at: 0)
//                    print(ModelPost(dictionary: diff.document.data())!)
                    //                    DispatchQueue.main.async {
                    //                        self.tableView.reloadData()
                    //                    }
                }
                self.tableView.reloadData()


            }
        }

        //        postsRef.addSnapshotListener {querySnapshot, error in
        //            print("is main thread:\(Thread.isMainThread)")
        //            guard let snapshot = querySnapshot else {return}
        //            print("--------------------update postList:")
        //            print(snapshot.documents)
        //            snapshot.documentChanges.forEach {
        //                diff in
        //                print(ModelPost(dictionary: diff.document.data())!)
        //                if diff.type == .added{
        //                    self.postList.append(ModelPost(dictionary: diff.document.data())!)
        //                    print(ModelPost(dictionary: diff.document.data())!)
        //
        //
        //                    //                    DispatchQueue.main.async {
        //                    //                        self.tableView.reloadData()
        //                    //                    }
        //                }
        ////                print("--------------------update self.postList")
        ////                print(self.postList)
        //
        //
        //            }
        //            self.tableView.reloadData()
        //        }

    }
    

    
    func callSegueFromCell(postId: String) {
        self.performSegue(withIdentifier: "showPostComments", sender:postId)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showPostComments"{
            let post = (segue.destination as! UINavigationController).topViewController as! CommentsTableViewController
            post.postRef = sender as? String
        }
        
    }


}

extension HomeTableViewController {
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        
//        if let posts = postList {
//            return posts.count
//        }
//
//        return 0
        return postList.count
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return postList.count
        
//        if let _ = postList{
//            return 1
//        }
//        return 0
        if postList.count > 0{
            return 1
        }
        return 0
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.postCell, for: indexPath) as! PostCell
        //        let cell = UITableViewCell()
        cell.post = self.postList[indexPath.section]
        cell.selectionStyle = .none
//        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.postHeaderCell) as! PostHeaderCell

        cell.post = self.postList[section]
        cell.backgroundColor = UIColor.white

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return StoryBoard.postHeaderHeight
    }
    
    
    
}
