//
//  SearchViewController.swift
//  instapic
//
//  Created by Logesh Chinsu Palani on 16/10/18.
//  Copyright © 2018 Logesh Chinsu Palani. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    
    @IBOutlet weak var userTableView: UITableView!
    var searchBar = UISearchBar()
    var users: [ModelUser] = [ModelUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.frame.size.width = view.frame.size.width - 60
        
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let searchText = searchBar.text {
            if searchText.count == 0{
                suggestUsers()
            }

        }
        
    }
    
    func suggestUsers() {
        let activityIndicator = common.startLoader(onView: self.view)
        self.users.removeAll()
        self.userTableView.reloadData()
        var tempUsers:[ModelUser] = [ModelUser]()
        UserService.getSuggestUsers(completion: {(user) in
            if let tUser = user{
                tempUsers.append(tUser)

            }else{
                self.users = tempUsers.removingDuplicates(byKey: \.userId)
                self.userTableView.reloadData()
                common.stopLoader(activityIndicator: activityIndicator)
            }
            
        })
        
    }
    
    func userSearch() {
        if let searchText = searchBar.text {
            if searchText.count > 1{
                self.users.removeAll()
                self.userTableView.reloadData()
                UserService.getUsersByUsername(withText: searchText, completion: {(users) in
                    self.users = users
                    self.userTableView.reloadData()
                })
            }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        if segue.identifier == "Search_ProfileSegue" {
        //            let profileVC = segue.destination as! ProfileUserViewController
        //            let userId = sender  as! String
        //            profileVC.userId = userId
        //            profileVC.delegate = self
        //        }
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //        userSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        userSearch()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        let user = users[indexPath.row]
        cell.user = user
        cell.delegate = self
        return cell
    }
}
extension SearchViewController: UserTableViewCellDelegate {
    func userProfileDetails(userId: String) {
        performSegue(withIdentifier: "Search_ProfileSegue", sender: userId)
    }
}

extension SearchViewController: HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: ModelUser) {
        //        self.users.filter({$0.userId == user.userId}).first?.isFollowing = user.isFollowing
        
        if let row = self.users.index(where: {$0.userId == user.userId}) {
            self.users[row].isFollowing = user.isFollowing
        }
        self.userTableView.reloadData()
        
        //        for u in users {
        //            if u.userId == user.userId {
        //                u.isFollowing = user.isFollowing
        //
        //            }
        //        }
    }
}
