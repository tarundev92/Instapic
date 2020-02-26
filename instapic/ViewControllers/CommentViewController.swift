//
//  CommentViewController.swift
//  instapic
//
//  Created by Deshna Jain on 17/10/18.
//  Copyright © 2018 Deshna Jain. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class CommentViewController: UIViewController {
    @IBOutlet weak var commentTxtFld: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    var db:Firestore!
    var commentCollectionRefString:String!
    var commentCollectionRef:CollectionReference!
    let profileRefString = "\(userProfile.collectionName)/Profile_"
    let currentUser = Auth.auth().currentUser
    var currentUsername: String!
    var currentUserImageUrl: String!
    var postRef: String?
    var commentList = [ModelComment]()
    
    var postId: String!
//    var commentList = [ModelComment]()
//    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("-----------------postRef:\(self.postRef!)")
        
        db = Firestore.firestore()
        commentCollectionRefString = "\(self.postRef!)/\(commentsObj.collectionName)"
        commentCollectionRef = db.collection(commentCollectionRefString)
        
        self.fetchUser(profileRefString: profileRefString, uid: currentUser!.uid, completed: {result in
            self.currentUsername = result[commentsObj.userNameKey] as? String
            self.currentUserImageUrl = result[commentsObj.userImageURLKey] as? String
            
        })
        
        title = "Comment"
        tableView.dataSource = self
        tableView.estimatedRowHeight = 77
        tableView.rowHeight = UITableViewAutomaticDimension
        empty()
        handleTextField()
        loadComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
//        print(notification)
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = keyboardFrame!.height
            self.view.layoutIfNeeded()
            
        }
    }
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = 0
            self.view.layoutIfNeeded()
            
        }
    }
    
    
    func loadComments() {
        let activityIndicator = common.startLoader(onView: self.view)
        
        fetchEachComment(completed: {comment in
            self.commentList.append(comment)
            self.tableView.reloadData()
            common.stopLoader(activityIndicator: activityIndicator)
        })
        common.stopLoader(activityIndicator: activityIndicator)
        

    }
    
    func fetchEachComment(completed:  @escaping (ModelComment) -> Void ){
        commentCollectionRef.order(by: commentsObj.createdKey, descending: false).getDocuments(){
            querySnapshot, error in
            if let error = error{
                print("Error:\(error.localizedDescription)")
                
            }else{
                //                var queryData = [[String: Any]]()
                
                for document in querySnapshot!.documents{
                    //                    print(document)
                    //                    print(document.documentID)
                    var tempComment = document.data()
                    
                    tempComment[commentsObj.commentDocRefKey] = "\(self.commentCollectionRefString!)/\(document.documentID)"
                    
                    self.fetchUser(profileRefString: self.profileRefString, uid: tempComment[commentsObj.userIdKey] as! String, completed: {
                        userData in
                        
                        tempComment[commentsObj.userNameKey] = userData[commentsObj.userNameKey]
                        tempComment[commentsObj.userImageURLKey] = userData[commentsObj.userImageURLKey]
                        
                        completed(ModelComment(dictionary: tempComment)!)
                        
                    })
                    
                    
                    
                }
                
            }
        }
        
    }
    
    func fetchUser(profileRefString: String, uid: String, completed:  @escaping ([String:Any]) -> Void ) {
        var userData:[String:Any] = [:]
        self.db.document("\(profileRefString)\(uid)").getDocument(){
            profileDocument, error in
            if let error = error{
//                print("Error:\(error.localizedDescription)")
//                common.stopLoader(activityIndicator: activityIndicator)
            }else{
                userData[commentsObj.userNameKey] = profileDocument!.data()![userProfile.usernameKey]
                userData[commentsObj.userImageURLKey] = profileDocument?.data()![userProfile.picURLKey]
//                print("fetch user info")
                completed(userData)
                
                
            }
        }
    }
    
    func handleTextField() {
        commentTxtFld.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        if let commentText = commentTxtFld.text, !commentText.isEmpty {
            sendBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
            sendBtn.isEnabled = true
            return
        }
        sendBtn.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
        sendBtn.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func sendBtn_TouchUpInside(_ sender: Any) {
//        let commentCollectionRef = db.collection("\(self.postRef!)/\(commentsObj.collectionName)")

//        guard let currentUser = Auth.auth().currentUser else  {
//            return
//        }
        let activityIndicator = common.startLoader(onView: self.view)
        let commentObject = [
            commentsObj.userIdKey: currentUser!.uid,
            commentsObj.commentKey: commentTxtFld.text!,
            commentsObj.createdKey: Date()
            ] as [String:Any]
        
        let newComment = commentCollectionRef.addDocument(data: commentObject)
        newComment.getDocument(){
            document, error in
            
            guard var newCommentData = document!.data() else { return }
            newCommentData[commentsObj.commentDocRefKey] = newComment.path
            newCommentData[commentsObj.userNameKey] = self.currentUsername
            newCommentData[commentsObj.userImageURLKey] = self.currentUserImageUrl
            
            
            
            self.commentList.append(ModelComment(dictionary: newCommentData)!)
            self.tableView.reloadData()
            
            self.empty()
            self.view.endEditing(true)
            common.stopLoader(activityIndicator: activityIndicator)
        }
        

    }

    
    func empty() {
        self.commentTxtFld.text = ""
        self.sendBtn.isEnabled = false
        sendBtn.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "Comment_ProfileSegue" {
//            let profileVC = segue.destination as! ProfileUserViewController
//            let userId = sender  as! String
//            profileVC.userId = userId
//        }
    }
}

extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let comment = commentList[indexPath.row]
//        let user = users[indexPath.row]
        cell.comment = comment
//        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension CommentViewController: CommentCellDelegate {
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Comment_ProfileSegue", sender: userId)
    }
}
