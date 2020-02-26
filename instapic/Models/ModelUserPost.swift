//
//  ModelUserPost.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 02/10/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit

struct ModelUserPost{
    var postImage: UIImage
    var documentReference: String
    var profileReference: String

}


//import Foundation
//import FirebaseFirestore
//
//protocol DocumentSerializable {
//    init?(dictionary:[String:Any])
//}
//let posts = Posts()
//
//struct ModelUserPost{
//    var docId:String
//    var imageURL:String
//
//    var dictionary:[String:Any]{
//        return [
//            "docId": docId,
//            posts.imageURLKey: imageURL
//        ]
//    }
//
//}
//
//extension ModelUserPost : DocumentSerializable {
//    init?(dictionary: [String:Any]) {
//        guard let docId = dictionary[posts.captionKey] as? String,
//            let imageURL = dictionary[posts.imageURLKey] as? String, else {
//                print("returning nil----------------")
//                return nil}
//
//        self.init(docId: docId, imageURL: imageURL)
//    }
//}
