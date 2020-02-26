//
//  FirstViewController.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 26/09/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import MultipeerConnectivity

class HomeViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    
    var db:Firestore!
    let userProfile = UserProfile()
    let common = Common()
    let posts = Posts()
    var currentUserProfData:[String:Any] = [:]
    var followingPostListener:[String:ListenerRegistration] = [:]
    var postList = [ModelPost]()
//    var postList1 = [ModelPost]()
    @IBOutlet weak var connectivityBtn: UIBarButtonItem!
    
    var peerID:MCPeerID!
    var mcSession:MCSession!
    var mcAdvertiserAssistant:MCAdvertiserAssistant!
    
    struct StoryBoard {
        static let postCell = "PostCell"
//        static let postHeaderCell = "PostHeaderCell"
//        static let postHeaderHeight: CGFloat = 57.0
        static let postCellDefaultHeight:CGFloat = 525
    }
    
    @IBOutlet weak var postsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        db = Firestore.firestore()
//        postsTableView.dataSource = self
        
        postsTableView.estimatedRowHeight = StoryBoard.postCellDefaultHeight
        postsTableView.rowHeight = UITableViewAutomaticDimension
        postsTableView.separatorColor = UIColor.clear
        postsTableView.dataSource = self
        
//        loadPosts()
//        checkPostsUpdate()
        loadPPosts()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loadPosts(){
        
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let activityIndicator = common.startLoader(onView: self.view)
        //        print("\(userProfile.collectionName) > Profile_\(uid) > \(posts.collectionName)")
        
        db.collection(userProfile.collectionName).document("Profile_\(uid)").collection(posts.collectionName).getDocuments(){
            querySnapshot, error in
            if let error = error{
                print("Error:\(error.localizedDescription)")
                self.common.stopLoader(activityIndicator: activityIndicator)
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
                self.postsTableView.reloadData()
                self.common.stopLoader(activityIndicator: activityIndicator)
                //                DispatchQueue.main.async {
                //                    self.tableView.reloadData()
                //                }
            }
        }
        
        
        
    }
    
    func profileListner(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.db.collection(self.userProfile.collectionName).document("Profile_\(uid)")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
//                    print("Document data was empty.")
                    return
                }
                
//                print("Current data: \(data)")
                var recentFollowingMembers:[String] = []
                if let trecentFollowingMembers = data[self.userProfile.followingKey] as? [String]{
                    recentFollowingMembers = trecentFollowingMembers
                }
                
                var oldFollowingMembers:[String] = []
                if let toldFollowingMembers = self.currentUserProfData[self.userProfile.followingKey] as? [String] {
                    oldFollowingMembers = toldFollowingMembers
                }
                if(recentFollowingMembers != oldFollowingMembers){
                    self.currentUserProfData[self.userProfile.followingKey] = recentFollowingMembers
                    let newFollowingMembers = recentFollowingMembers.filter(){!oldFollowingMembers.contains($0)}
                    let removedFollowingMembers = oldFollowingMembers.filter(){!recentFollowingMembers.contains($0)}
                    
                    for userId in newFollowingMembers{
                        let userRef = "\(self.userProfile.collectionName)/\(userId)"
                        self.fetchUser(userDocRef: userRef, completed: {
                            userData in
//                            print("following :\(userRef)/\(self.posts.collectionName)")
                            let activityIndicator = self.common.startLoader(onView: self.view)
                            self.populatePostList(userRef: userRef, userId: userId, userData: userData, activityIndicator: activityIndicator)
                            self.addSnapshotListenerToPost(userId: userId, userRef: userRef, userData:userData)
//                            print("self.postList:\(self.postList)")
                        })

                    }
                    
                    for userId in removedFollowingMembers{
                        let userUID = userId.split(separator: "_")[1]
                        self.postList = self.postList.filter(){$0.userId != userUID}
                        self.followingPostListener[userId]!.remove()
                        self.followingPostListener.removeValue(forKey: userId)
                    }
                    self.postsTableView.reloadData()
                    
                }
                
//                if let username = data[self.userProfile.usernameKey] as? String{
//
//                    //                    print("username: \(type(of:username))")
//                    self.userNameLbl.text = username
//                    var postCount = 0
//                    var followerCount = 0
//                    var followingCount = 0
//                    if let tempfollowerCount = data[self.userProfile.followersCountKey] as? Int{
//                        followerCount = tempfollowerCount
//                    }
//                    if let tempfollowingCount = data[self.userProfile.followingCountKey] as? Int{
//                        followingCount = tempfollowingCount
//                    }
//                    if let tempPostCount = data[self.userProfile.postCountKey] as? Int{
//                        postCount = tempPostCount
//                    }
//
//                    self.followersCountLbl.text = "\(followerCount)"
//                    self.followingCountLbl.text = "\(followingCount)"
//                    self.postCountLbl.text = "\(postCount)"
//
//                    if let picURL = data[self.userProfile.picURLKey] as? String {
//                        self.profilePicView.image = self.common.getImageDtaFromURL(imageURL: picURL)
//                    }
//
//                }
                
                
        }
    }
    
    func loadPPosts(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let activityIndicator = common.startLoader(onView: self.view)
        let userCollection = "\(userProfile.collectionName)/Profile_"
        let currentUserProfileString = "\(userCollection)\(uid)"
        let currentUserProfile = db.document(currentUserProfileString)
        currentUserProfile.getDocument(){
            queryDoc, error in
            if let error = error{
                print("Error:\(error.localizedDescription)")
            }else{
                guard let document = queryDoc else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let currentUserData = document.data() else { return }
                
                self.currentUserProfData[self.userProfile.usernameKey] = currentUserData[self.userProfile.usernameKey]
                self.currentUserProfData[self.userProfile.picURLKey] = currentUserData[self.userProfile.picURLKey]
                self.currentUserProfData[self.userProfile.followingKey] = currentUserData[self.userProfile.followingKey]
                self.profileListner()
                self.db.collection("\(currentUserProfileString)/\(self.posts.collectionName)").getDocuments(){
                    querySnapshot, error in
                    if let error = error {
                        print("\(error.localizedDescription)")
                    }else{
                        for document in querySnapshot!.documents{
                            var tempPost = document.data()
                            tempPost[self.posts.postDocRefKey] = "\(self.userProfile.collectionName)/Profile_\(uid)/\(self.posts.collectionName)/\(document.documentID)"
                            tempPost[self.posts.userIdKey] = uid
                            tempPost[self.posts.userNameKey] = currentUserData[self.userProfile.usernameKey]
                            tempPost[self.posts.userImageURLKey] = currentUserData[self.userProfile.picURLKey]
                            self.postList.append(ModelPost(dictionary: tempPost)!)
                        }
                        self.postList =  self.postList.sorted(by: {$0.createdAt > $1.createdAt})
//                        print("self.postList:\(self.postList)")
                        self.postsTableView.reloadData()
                    }
                }
                self.checkPostsUpdate()
                
                var following:[String] = []
                if let tempFollowing = currentUserData[self.userProfile.followingKey] as? [String] {
                    following = tempFollowing
                }
//                print("user following list: \(following)")
                for userId in following{
                    let userRef = "\(self.userProfile.collectionName)/\(userId)"
//                    print("userRef:\(userRef)")
                    self.fetchUser(userDocRef: userRef, completed: {
                        userData in
//                        print("following :\(userRef)/\(self.posts.collectionName)")
//                        self.db.collection("\(userRef)/\(self.posts.collectionName)").getDocuments(){
//                            querySnapshot, error in
//                            if let error = error{
//                                print("\(error.localizedDescription)")
//                            }else{
////                                var queryData = [[String: Any]]()
//                                for document in querySnapshot!.documents{
//                                    var tempPost = document.data()
//                                    tempPost[self.posts.postDocRefKey] = "\(self.userProfile.collectionName)/\(userId)/\(self.posts.collectionName)/\(document.documentID)"
//                                    tempPost[self.posts.userIdKey] = String(userId.split(separator: "_")[1])
//                                    tempPost[self.posts.userNameKey] = userData[self.userProfile.usernameKey]
//                                    tempPost[self.posts.userImageURLKey] = userData[self.userProfile.picURLKey]
//                                    self.postList.append(ModelPost(dictionary: tempPost)!)
//                                }
//                                print("following self.postList: \(self.postList)")
//                                self.postList =  self.postList.sorted(by: {$0.createdAt.seconds > $1.createdAt.seconds})
//                                self.postsTableView.reloadData()
//                                self.common.stopLoader(activityIndicator: activityIndicator)
//                            }
//                        }
                        self.populatePostList(userRef: userRef, userId: userId, userData: userData, activityIndicator: activityIndicator)

                        
                        self.addSnapshotListenerToPost(userId: userId, userRef: userRef, userData:userData)
//                        print("self.postList:\(self.postList)")
                        
                    })
                    
                }
//                print("self.postList:\(self.postList)")
                self.postsTableView.reloadData()
                self.common.stopLoader(activityIndicator: activityIndicator)
                
                
            }
        }
        
    }
    
    func populatePostList(userRef: String, userId: String, userData: [String:Any], activityIndicator: UIActivityIndicatorView){
        self.db.collection("\(userRef)/\(self.posts.collectionName)").getDocuments(){
            querySnapshot, error in
            if let error = error{
                print("\(error.localizedDescription)")
            }else{
                //                                var queryData = [[String: Any]]()
                for document in querySnapshot!.documents{
                    var tempPost = document.data()
                    tempPost[self.posts.postDocRefKey] = "\(self.userProfile.collectionName)/\(userId)/\(self.posts.collectionName)/\(document.documentID)"
                    tempPost[self.posts.userIdKey] = String(userId.split(separator: "_")[1])
                    tempPost[self.posts.userNameKey] = userData[self.userProfile.usernameKey]
                    tempPost[self.posts.userImageURLKey] = userData[self.userProfile.picURLKey]
                    self.postList.append(ModelPost(dictionary: tempPost)!)
                }
//                print("following self.postList: \(self.postList)")
                self.postList =  self.postList.sorted(by: {$0.createdAt > $1.createdAt})
                self.postsTableView.reloadData()
                self.common.stopLoader(activityIndicator: activityIndicator)
            }
        }
    }
    
    func addSnapshotListenerToPost(userId: String, userRef: String, userData:[String:Any]){
        self.followingPostListener[userId] = self.db.collection("\(userRef)/\(self.posts.collectionName)").whereField(self.posts.createdKey, isGreaterThan: Date()).addSnapshotListener {querySnapshot, error in
            guard let snapshot = querySnapshot else {return}
            
            snapshot.documentChanges.forEach {
                diff in
                
                if diff.type == .added{
                    var tempPost = diff.document.data()
                    tempPost[self.posts.postDocRefKey] = "\(self.userProfile.collectionName)/\(userId)/\(self.posts.collectionName)/\(diff.document.documentID)"
                    tempPost[self.posts.userIdKey] = String(userId.split(separator: "_")[1])
                    tempPost[self.posts.userNameKey] = userData[self.userProfile.usernameKey]
                    tempPost[self.posts.userImageURLKey] = userData[self.userProfile.picURLKey]
                    self.postList.insert(ModelPost(dictionary: tempPost)!, at: 0)
                }
                self.postsTableView.reloadData()
                
            }
            
        }
        
    }

    
    func fetchUser(userDocRef: String, completed:  @escaping ([String:String]) -> Void ){
        self.db.document(userDocRef).getDocument(){
            querySnap, error in
            if let error = error{
                print("error: \(error.localizedDescription)")
            }else{
                guard let document = querySnap else { return }
                guard let userData = document.data() else { return }
                let username = userData[self.userProfile.usernameKey] as! String
                let imageURL = userData[self.userProfile.picURLKey] as! String
                completed([self.userProfile.usernameKey: username, self.userProfile.picURLKey: imageURL])
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
                    tempPost[self.posts.userIdKey] = uid
                    tempPost[self.posts.userNameKey] = self.currentUserProfData[self.userProfile.usernameKey]
                    tempPost[self.posts.userImageURLKey] = self.currentUserProfData[self.userProfile.picURLKey]
                    self.postList.insert(ModelPost(dictionary: tempPost)!, at: 0)
                    //                    print(ModelPost(dictionary: diff.document.data())!)
                    //                    DispatchQueue.main.async {
                    //                        self.tableView.reloadData()
                    //                    }
                }
                self.postsTableView.reloadData()
                
                
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postRef = sender  as! String
            commentVC.postRef = postRef
        }
        
//        if segue.identifier == "Home_ProfileSegue" {
//            let profileVC = segue.destination as! ProfileUserViewController
//            let userId = sender  as! String
//            profileVC.userId = userId
//        }
        if segue.identifier == "LikeSegue" {
            let likeVC = segue.destination as! LikesViewController
            let postRef = sender  as! String
            likeVC.postRef = postRef
        }
        
    }
    
    
    @IBAction func showConnectivityAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Post Exchange", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action:UIAlertAction) in
            
            self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "post-sharing", discoveryInfo: nil, session: self.mcSession)
            self.mcAdvertiserAssistant.start()
            self.connectivityBtn.image = UIImage(named: "swap_vert_black_18dp")
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action:UIAlertAction) in
            let mcBrowser = MCBrowserViewController(serviceType: "post-sharing", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("session data:", data)
        
        do {
            let postObj = try JSONDecoder().decode(ModelPost.self, from: data)
            
            DispatchQueue.main.async {
                self.postList.insert(postObj, at: 0)
                self.postsTableView.reloadData()
            }


        }catch{
            fatalError("Unable to process recieved data")
        }
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: {
            
            self.connectivityBtn.image = UIImage(named: "swap_vert_black_18dp")
        })
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: {
            self.connectivityBtn.image = UIImage(named: "cast_connected_black_18dp")
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension HomeViewController: UITableViewDataSource {



//    override func numberOfSections(in tableView: UITableView) -> Int {
//        if let posts = postList{
//            return posts.count
//        }
//        return 0
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postList.count

//        if let _ = postList{
//            return 1
//        }
//        return 0


    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("reload cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.postCell, for: indexPath) as! PostCell
//        let cell = UITableViewCell()
        cell.post = self.postList[indexPath.row]
//        cell.selectionStyle = .none
        
        cell.delegate = self
//        print("return cell")
        return cell
    }

//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.postHeaderCell) as! PostHeaderCell
//
//        cell.post = self.postList?[section]
//        cell.backgroundColor = UIColor.white
//        return cell
//    }

}
extension HomeViewController: PostCellDelegate {
    func segueToCommentVC(postRef: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postRef)
    }
    func segueToProfileUserVC(userRef: String) {
        performSegue(withIdentifier: "ProfileSegue", sender: userRef)
    }
    func segueToLikeVC(postRef: String) {
        performSegue(withIdentifier: "LikeSegue", sender: postRef)
    }
    
    func sharePost(post: ModelPost) {
        if mcSession.connectedPeers.count>0{
//            let data:Data = post
            let encoder = JSONEncoder()
            do {
                var postObj = post
                postObj.isInRange = true
                let data = try encoder.encode(postObj)
                do {
                    try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
                }catch{
                    fatalError("Could not send post")
                }
            }catch{
                fatalError(error.localizedDescription)
            }
            
        }else{
            let alert = UIAlertController(title: "Info", message: "Not connected to any host!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        }
//        performSegue(withIdentifier: "LikeSegue", sender: postRef)
    }
    
}
