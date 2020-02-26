//
//  DiscoverViewController.swift
//  instapic
//
//  Created by Logesh Chinsu Palani on 16/10/18.
//  Copyright © 2018 Logesh Chinsu Palani. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {

    var postList:[ModelUserPost] = []
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        postCollectionView.dataSource = self
        postCollectionView.delegate = self

        
        getTopPosts()
    }
    
    @IBAction func refreshTopPostBtn(_ sender: Any) {
        getTopPosts()
    }
    
    func getTopPosts() {

        let activityIndicator = common.startLoader(onView: self.postCollectionView)
        self.postList.removeAll()
        self.postCollectionView.reloadData()
        PostService.getTopUserPosts(completion: {topPost in
            if let topPost = topPost{
                self.postList.append(topPost)
            }else{
                self.postCollectionView.reloadData()
                common.stopLoader(activityIndicator: activityIndicator)
            }
            
            
            
        })
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "PostDetailSegue" {
//            let detailVC = segue.destination as! DetailViewController
//            let postId = sender  as! String
//            detailVC.postId = postId
//        }
        
        if segue.identifier == "PostDetailSegue"{
            let userPost = segue.destination as! PostDetailViewController
            userPost.userPostDetail = sender as? [String: Any]
        }
    }

}

extension DiscoverViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! PicCollectionViewCell
        let post = postList[indexPath.row]
        cell.post = post
        cell.delegate = self
        
        return cell
    }
}

extension DiscoverViewController: UICollectionViewDelegateFlowLayout {
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

extension DiscoverViewController: PicCollectionViewCellDelegate {
    func postDetailSegue(postDetails: [String:Any]) {
        performSegue(withIdentifier: "PostDetailSegue", sender: postDetails)
    }
    
}
