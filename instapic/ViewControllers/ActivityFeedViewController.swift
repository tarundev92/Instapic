//
//  ActivityFeedViewController.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 19/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class ActivityFeedViewController: UIViewController {
    
    @IBOutlet weak var activitySegmentedControl: UISegmentedControl!
    @IBOutlet weak var activityTableView: UITableView!
    var followingActivity = [ModelActivity]()
    var yourActivity = [ModelActivity]()
    override func viewDidLoad() {
        super.viewDidLoad()
        activityTableView.dataSource = self
        activityTableView.estimatedRowHeight = 77
        activityTableView.rowHeight = UITableViewAutomaticDimension
        loadActivityFeed()
        checkActivityFeedUpdate()
        
    }
    
    func loadActivityFeed(){
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let activityIndicator = common.startLoader(onView: self.activityTableView)
        
        let docRef = "\(userProfile.collectionName)/Profile_\(uid)/\(activity.collectionName)"
        db.collection(docRef).order(by: activity.createdKey, descending: true).getDocuments(){
            querySnapshot, error in
            if let error = error{
                print("Error:\(error.localizedDescription)")
            }else{
                for document in querySnapshot!.documents {
                    //                    print("\(document.documentID) => \(document.data())")
                    if(document.data()[activity.isYouKey] as! Bool){
                        self.yourActivity.append(ModelActivity(dictionary: document.data())!)
                    }else{
                        self.followingActivity.append(ModelActivity(dictionary: document.data())!)
                    }
                    
                }
                
//                print("self.yourActivity:\(self.yourActivity)")
//                print("self.followingActivity\(self.followingActivity)")
                self.activityTableView.reloadData()
                common.stopLoader(activityIndicator: activityIndicator)

            }
        }
        
    }
    
    func checkActivityFeedUpdate(){
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docRef = "\(userProfile.collectionName)/Profile_\(uid)/\(activity.collectionName)"
        //        var postsRef = db.collection(docRef)
        
        db.collection(docRef).whereField(activity.createdKey, isGreaterThan: Date()).addSnapshotListener {querySnapshot, error in
            guard let snapshot = querySnapshot else {return}
            
            snapshot.documentChanges.forEach {
                diff in
                
                if diff.type == .added{
                    if(diff.document.data()[activity.isYouKey] as! Bool){
                        self.yourActivity.insert(ModelActivity(dictionary: diff.document.data())!, at: 0)
                    }else{
                        self.followingActivity.insert(ModelActivity(dictionary: diff.document.data())!, at: 0)
                    }

                }
//                print("self.yourActivity:\(self.yourActivity)")
//                print("self.followingActivity\(self.followingActivity)")
                self.activityTableView.reloadData()
                
                
            }
        }
    }
    

    
    @IBAction func segmentedControlActionChanged(_ sender: Any) {
//        let activityIndicator = common.startLoader(onView: self.view)
        self.activityTableView.reloadData()
//        common.stopLoader(activityIndicator: activityIndicator)
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

extension ActivityFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
//        print("numberOfRowsInSection seg sel: \(activitySegmentedControl.selectedSegmentIndex)")
        switch (activitySegmentedControl.selectedSegmentIndex) {
        case 0:
            returnValue = followingActivity.count
            break
        case 1:
            returnValue = yourActivity.count
            break
        default:

            break
        }
        return returnValue
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityFeedCell", for: indexPath) as! ActivityFeedCell
//        print("cellForRowAt seg sel: \(activitySegmentedControl.selectedSegmentIndex)")
        switch (activitySegmentedControl.selectedSegmentIndex) {
        case 0:
            let cellActivity = followingActivity[indexPath.row]
            //        let user = users[indexPath.row]
            cell.activity = cellActivity
            //        cell.user = user
            //        cell.delegate = self
            break
        case 1:
            let cellActivity = yourActivity[indexPath.row]
            //        let user = users[indexPath.row]
            cell.activity = cellActivity
            //        cell.user = user
            //        cell.delegate = self
            break
        default:
            break
        }
        

        return cell
    }
    

}

//extension ActivityFeedViewController: CommentTableViewCellDelegate {
//    func goToProfileUserVC(userId: String) {
//        performSegue(withIdentifier: "Comment_ProfileSegue", sender: userId)
//    }
//}
