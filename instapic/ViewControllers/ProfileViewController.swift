//
//  ProfileView.swift
//  instagram
//
//  Created by Tarun Dev Thalakunte Rajappa on 17/09/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import Firebase
class ProfileViewController: UIViewController {
    
    let db = Firestore.firestore()
    let userProfile = UserProfile()
    let posts = Posts()
    let common = Common()
    var user:ModelUser!
//    @IBOutlet weak var profilePicView: UIImageView!
//    var datasource: UserPostDataSource = UserPostDataSource()
//    var presenter: UserPostPresenter = UserPostPresenter()
    var userPostObjects: [ModelUserPost] = []
    @IBOutlet weak var userPostCollectionView: UICollectionView!
//    @IBOutlet weak var userNameLbl: UILabel!
//    @IBOutlet weak var editProfileBtn: UIButton!{
//        didSet {
//            editProfileBtn.layer.cornerRadius =  4.0
//            editProfileBtn.layer.borderColor = UIColor().colorFromHex("C6C6C8").cgColor
//            editProfileBtn.layer.borderWidth = 1
//        }
//    }
//    @IBOutlet weak var postCountLbl: UILabel!
//    @IBOutlet weak var followersCountLbl: UILabel!
//    @IBOutlet weak var followingCountLbl: UILabel!
    
//    var imagePicker:UIImagePickerController!
    
    
    func setup(){
        
        userPostCollectionView.dataSource = self
        userPostCollectionView.delegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
//        profilePicView.isUserInteractionEnabled = true
//        profilePicView.addGestureRecognizer(imageTap)
//        profilePicView.layer.cornerRadius = profilePicView.frame.size.width / 2
//        profilePicView.clipsToBounds = true
//        profilePicView.layer.borderWidth = 2
//        profilePicView.layer.borderColor = UIColor.black.cgColor
        //        tapToChangeProfileButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        
//        imagePicker = UIImagePickerController()
//        imagePicker.allowsEditing = true
//        imagePicker.sourceType = .photoLibrary
//        imagePicker.delegate = self
//
        updateView()
        setup()
        fillUserPosts()
        checkPostsUpdate()
        
        // Do any additional setup after loading the view.
    }
    
    func fillUserPosts(){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let activityIndicator = common.startLoader(onView: self.userPostCollectionView)
        
        let docRef = "\(self.userProfile.collectionName)/Profile_\(uid)/\(self.posts.collectionName)"
        db.collection(docRef).order(by: posts.createdKey, descending: true).getDocuments(){
            querySnapshot, error in
            if let error = error{
                print("Error:\(error.localizedDescription)")
            }else{
                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    print("fillUserPosts before append")
                    self.userPostObjects.append(ModelUserPost(postImage: self.common.getImageDtaFromURL(imageURL: document.data()[self.posts.imageURLKey] as! String), documentReference: "\(docRef)/\(document.documentID)",
                        profileReference: "\(self.userProfile.collectionName)/Profile_\(uid)"))
                }
                
//                self.userPosts = (objects: self.userPostObjects)
//                print("fillUserPosts before reload  ")
                self.userPostCollectionView.reloadData()
                self.common.stopLoader(activityIndicator: activityIndicator)
                
                //                self.collectionView()
                //                self.objects = querySnapshot!.documents.compactMap({ModelPost(dictionary: $0.data())})
            }
        }
        
    }
    
    func checkPostsUpdate(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docRef = "\(self.userProfile.collectionName)/Profile_\(uid)/\(self.posts.collectionName)"
//        var postsRef = db.collection(docRef)
        
        db.collection(docRef).whereField(posts.createdKey, isGreaterThan: Date()).addSnapshotListener {querySnapshot, error in
            guard let snapshot = querySnapshot else {return}

            snapshot.documentChanges.forEach {
                diff in

                if diff.type == .added{
//                    print("checkPostsUpdate before insert")
                    self.userPostObjects.insert(ModelUserPost(postImage: self.common.getImageDtaFromURL(imageURL: diff.document.data()[self.posts.imageURLKey] as! String), documentReference: "\(docRef)/\(diff.document.documentID)", profileReference: "Profile_\(uid)"), at: 0)
                    
                    //                    DispatchQueue.main.async {
                    //                        self.postsTableView.reloadData()
                    //                    }
                }
//                print("checkPostsUpdate before reload  ")
//                self.datasource.fill(objects: self.userPostObjects)
                self.userPostCollectionView.reloadData()
                
                
            }
        }
        
    }
    
    func updateView(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection(self.userProfile.collectionName).document("Profile_\(uid)")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard var data = document.data() else {
//                    print("Document data was empty.")
                    return
                }
                
//                print("Current data: \(data)")
                data[self.userProfile.uidKey] = "\(document.documentID)"
                self.user = ModelUser(dictionary: data)
                self.navigationItem.title = self.user.username
                self.userPostCollectionView.reloadData()
//                if let username = data[self.userProfile.usernameKey] as? String{
//
////                    print("username: \(type(of:username))")
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
//                         self.profilePicView.image = self.common.getImageDtaFromURL(imageURL: picURL)
//                    }
//
//                }
                
                
        }

        
        
        
//        let profileRef = db.collection("UserProfiles").document("Profile_\(uid)")
//
//        profileRef.getDocument{(document, error) in
//            if let document = document, document.exists {
//
//
//                if let doc = document.data(),
//                    let username = doc[self.userProfile.usernameKey] as? String,
//                    let picURL = doc[self.userProfile.picURLKey] as? String {
//                    print("username: \(username)")
//                    print("username: \(type(of:username))")
//                    self.userNameLbl.text = username
//                    do {
//                        let url = URL(string: picURL)
//                        let data = try Data(contentsOf: url!)
//                        self.profilePicView.image = UIImage(data: data)
//                    }
//                    catch{
//                        print(error)
//                    }
//
//                }
//
//
//            } else {
//                print("Document does not exist")
//            }
//        }
        
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        //handle cell selection
//        guard let cell = collectionView.cellForItem(at: indexPath) as? UserPostCell else { return }
////        print("cell sel \(cell.imageRef))")
////        print("cell sel \(indexPath)")
//
//        let postDetails = ["postDocRef": cell.postDocRef, "profileDocRef": cell.profileDocRef]
//
//        performSegue(withIdentifier: "showUserPostDetail", sender: postDetails)
//
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

       
        if segue.identifier == "showUserPostDetail"{
            let userPost = segue.destination as! PostDetailViewController
            userPost.userPostDetail = sender as? [String:Any]
        }
        
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    //        return 0.0
    //    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    //    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let size: CGFloat = collectionView.frame.width/3
//
//        return CGSize(width: size, height: size)
//    }
    
//    @objc func openImagePicker(_ sender:Any) {
//        // Open Image Picker
//        self.present(imagePicker, animated: true, completion: nil)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func logOut(_ sender: Any) {
//        try! Auth.auth().signOut()
//        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let signInVC = storyboard.instantiateViewController(withIdentifier: "ViewControllerSignIn")
//        self.present(signInVC, animated: true, completion: nil)
//        
////        self.performSegue(withIdentifier: "toLogInScreen", sender: nil)
//        
//        
//    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
//            self.profilePicView.image = selectedImage
//        }
//
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//
//}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPostObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPostCell", for: indexPath) as! UserPostCell
        let post = userPostObjects[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        if let user = self.user {
            headerViewCell.user = user
            headerViewCell.delegate2 = self
        }
        return headerViewCell
    }
    
}

extension ProfileViewController: HeaderProfileCollectionReusableViewDelegateEditProfile {
    func editProfileSegue() {
        performSegue(withIdentifier: "ProfileEditSegue", sender: nil)
    }
}


extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
}


extension ProfileViewController: UserPostCellDelegate {
    func userPostDetail(postDetails: [String:Any]) {
        performSegue(withIdentifier: "showUserPostDetail", sender: postDetails)
    }
}
