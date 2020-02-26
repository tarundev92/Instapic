//
//  Common.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 29/09/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Common {
    
    func uploadImageToCloud(_ image:UIImage, storagePath: String, completion: @escaping ((_ url:URL?)->())) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        
//        let storageRef = Storage.storage().reference().child("users/profile_pic_\(uid)")
        let storageRef = Storage.storage().reference().child(storagePath)
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.75) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                storageRef.downloadURL { url, error in
//                    print("upload url:\(url)")
                    completion(url)
                    // success!
                }
                // success!
            } else {
                // failed
                print("upload Image error:\(error!.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func uploadVideoToCloud(videoUrl: URL, storagePath: String, completion: @escaping ((_ url:URL?)->())) {
//        let videoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child(storagePath)
        storageRef.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
            if error != nil {
                print("upload Video error:\(error!.localizedDescription)")
                completion(nil)
            }else {
                storageRef.downloadURL { url, error in
                    //                    print("upload url:\(url)")
                    completion(url)
                    // success!
                }
            }
        }
    }
    
    
    func startLoader(onView : UIView) -> UIActivityIndicatorView {
        
        let activityIndicator = UIActivityIndicatorView(frame: onView.bounds)
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        activityIndicator.isUserInteractionEnabled = true
        onView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        return activityIndicator
    
    }
    
    func stopLoader(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    func getImageDtaFromURL(imageURL:String) -> UIImage{
        do {
            let url = URL(string: imageURL)
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)!
        }
        catch{
            print(error)
        }
        return UIImage()
    }
    
    
    func formatDate(date:Timestamp) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateObj = Date(timeIntervalSince1970: TimeInterval(date.seconds))
        let elapsedTimeInSec = NSDate().timeIntervalSince(dateObj)
        let secondInDays: TimeInterval = 60 * 60 * 24
        
        if elapsedTimeInSec > 7 * secondInDays {
            dateFormatter.dateFormat = "MM/dd/yy"
        }else if elapsedTimeInSec > secondInDays{
            dateFormatter.dateFormat = "EEE"
        }
        return dateFormatter.string(from: dateObj)
    }
    
    
    func timeAgoSince(dateTimestamp: Double) -> String {
        
        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let date = Date(timeIntervalSince1970: dateTimestamp)
        let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
        
        if let year = components.year, year >= 2 {
            return "\(year) years ago"
        }
        
        if let year = components.year, year >= 1 {
            return "Last year"
        }
        
        if let month = components.month, month >= 2 {
            return "\(month) months ago"
        }
        
        if let month = components.month, month >= 1 {
            return "Last month"
        }
        
        if let week = components.weekOfYear, week >= 2 {
            return "\(week) weeks ago"
        }
        
        if let week = components.weekOfYear, week >= 1 {
            return "Last week"
        }
        
        if let day = components.day, day >= 2 {
            return "\(day) days ago"
        }
        
        if let day = components.day, day >= 1 {
            return "Yesterday"
        }
        
        if let hour = components.hour, hour >= 2 {
            return "\(hour) hours ago"
        }
        
        if let hour = components.hour, hour >= 1 {
            return "An hour ago"
        }
        
        if let minute = components.minute, minute >= 2 {
            return "\(minute) minutes ago"
        }
        
        if let minute = components.minute, minute >= 1 {
            return "A minute ago"
        }
        
        if let second = components.second, second >= 3 {
            return "\(second) seconds ago"
        }
        
        return "Just now"
        
    }
    
}
let common = Common()
