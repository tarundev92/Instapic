//
//  CommentsTableViewController.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 09/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {
    var postRef: String?
    var commentList = [ModelComment]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let postRef = self.postRef else { return }
//        print("-----------postRef:\(postRef)")
        
//        var commentDocRef:String
//        var username:String
//        var userImageURL:String
//        var comment:String
//        var createdAt:Timestamp
        
        let comments = [
            ["commentDocRef": "sdsd", "userImageURL": "https://firebasestorage.googleapis.com/v0/b/instapic-bb197.appspot.com/o/users%2Fprofile_pic_2IrCcKCI5SgeopAT57RSiUE7e1H2?alt=media&token=25b9d968-26ae-4893-8705-e5aec68dba92", "createdAt": "Date()", "userName": "John", "comment": "Amazing application nice!"],
            ["commentDocRef": "sdsd", "userImageURL": "https://firebasestorage.googleapis.com/v0/b/instapic-bb197.appspot.com/o/users%2Fprofile_pic_2IrCcKCI5SgeopAT57RSiUE7e1H2?alt=media&token=25b9d968-26ae-4893-8705-e5aec68dba92", "createdAt": "Date()", "userName": "Samuel", "comment": "How can I add a photo to my profile? This is longer than the previous comment."]
        ]
        
        self.commentList = comments.compactMap({ModelComment(dictionary: $0)})
        
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.separatorColor = UIColor.clear
        
//        tableView.estimatedRowHeight = StoryBoard.postCellDefaultHeight
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.separatorColor = UIColor.clear
        
        self.tableView.reloadData()
        
        addComposeButtonToNavigationBar()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func addComposeButtonToNavigationBar() -> Void {
        let button = UIBarButtonItem(barButtonSystemItem: .compose,
                                     target: self,
                                     action: #selector(buttonTapped))
        navigationItem.setRightBarButton(button, animated: false)
    }
    
    @objc func buttonTapped() -> Void {
        let alert = UIAlertController(title: "Comment",
                                      message: "",
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = nil
            textField.placeholder = "Enter comment"
        }
        
        alert.addAction(UIAlertAction(title: "Add Comment", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            if (textField?.hasText)! {
                self.postComment(comment: (textField?.text)!)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func postComment(comment: String) -> Void {
//        Alamofire.request(MESSAGES_ENDPOINT, method: .post, parameters: ["comment": comment])
//            .validate()
//            .responseJSON { response in
//                switch response.result {
//                case .success:
//                    print("Posted successfully")
//                case .failure(let error):
//                    print(error)
//                }
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    

}

extension CommentsTableViewController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if commentList.count > 0{
            return commentList.count
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        cell.comment = self.commentList[indexPath.row]
        cell.selectionStyle = .none
//        cell.username?.text = "? " + (comments[indexPath.row]["username"] ?? "Anonymous")
//        cell.comment?.text  = comments[indexPath.row]["comment"]
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}
