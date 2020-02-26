//
//  ShareViewController.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 30/09/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class ShareViewController: UIViewController {

    @IBOutlet weak var imageCaption: UITextView!
    @IBOutlet weak var previewPhoto: UIImageView!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.tapToHideKeyboard()
//        print("self.image:\(self.image)")
        previewPhoto.image = self.image

        // Do any additional setup after loading the view.
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func cancelBtn(_ sender: Any) {
//        navigationController?.popToViewController(FirstViewController(), animated: true)
//        self.performSegue(withIdentifier: "showPostsView", sender: nil)
        
        self.tabBarController?.selectedIndex = 0
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
//        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareBtn(_ sender: Any) {
        guard let imageCaption = imageCaption.text else { return }
        guard let image = previewPhoto.image else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let userProfile = UserProfile()
        let common = Common()
        let posts = Posts()
        let activityIndicator = common.startLoader(onView: self.view)
        let postsRef = db.collection(userProfile.collectionName).document("Profile_\(uid)").collection(posts.collectionName)
        let storagePath = "\(uid)/post_\(Date().timeIntervalSince1970)"
        
        common.uploadImageToCloud(image, storagePath: storagePath) {url in
            let postObject = [
                posts.imageURLKey: url!.absoluteString,
                posts.captionKey: imageCaption,
                posts.likeCountKey: 0,
                posts.createdKey: Date()
                ] as [String:Any]
            
            postsRef.addDocument(data: postObject)
            UserService.updatePostCount(isPostAdded: true)
            
            common.stopLoader(activityIndicator: activityIndicator)
            self.tabBarController?.selectedIndex = 0
            self.navigationController?.popToRootViewController(animated: true)
//            self.dismiss(animated: true, completion: nil)
            
//            profileRef.document("Profile_\(uid)").updateData([userProfile.picURLKey: url!.absoluteString]){ error in
//                if let error = error {
//                    // Error
//                    print("------------------\(error.localizedDescription)")
//                }else{
//
//                }
//            }
            
            
            
        }
        
        
//        previewPhoto.image
//        imageCaption.text
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
