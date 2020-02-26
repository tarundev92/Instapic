//
//  ActivityFeedCell.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 19/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import KILabel

class ActivityFeedCell: UITableViewCell {

    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var activityMsgLbl: KILabel!
    @IBOutlet weak var activityCreatedLbl: UILabel!
    
    var activity: ModelActivity?{
        didSet{
            updateView()
        }
    }
    
    func updateView(){
//        print("activityCell update view")
        usernameLbl.text = activity?.username
        userImageView.image = common.getImageDtaFromURL(imageURL: activity!.userImageURL)
        activityMsgLbl.text = activity?.activityMsg
        activityCreatedLbl.text = common.timeAgoSince(dateTimestamp: TimeInterval(activity!.createdAt.seconds))
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
