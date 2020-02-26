//
//  PostHeaderCell.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 01/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit

class PostHeaderCell: UITableViewCell {

    
    @IBOutlet weak var profilePicView: UIImageView!
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    var post: ModelPost!{
//    var post: TempPost!{
        didSet{
            self.updateUI()
        }
    }
    
    func updateUI(){

        profilePicView.layer.cornerRadius = profilePicView.bounds.width / 2.0
        profilePicView.layer.masksToBounds = true
        
        usernameLbl.text = "Tarun Dev"
        
    }
}
