//
//  UserPostDataSource.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 02/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class UserPostDataSource: NSObject, UICollectionViewDataSource {
    
    var objects: [ModelUserPost] = []
    let db = Firestore.firestore()
    let userProfile = UserProfile()
    let posts = Posts()
    let common = Common()
    
    func fill(objects: [ModelUserPost]){
        
        self.objects = objects

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UserPostCell
        
        let userPost = objects[indexPath.item]
//        cell.fill(with: userPost)
//        cell.delegate = self
        
        
        return cell
    }

}
