//
//  ProfileEdit.swift
//  instagram
//
//  Created by Tarun Dev Thalakunte Rajappa on 17/09/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class ProfileEditController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var imagePicker:UIImagePickerController!
    var genderOption = ["Not Specified", "Male", "Female"]
    let common = Common()
    
    
    @IBOutlet weak var profileNameTxtField: UITextField!
    @IBOutlet weak var userNameTxtField: UITextField!
    @IBOutlet weak var websiteTxtField: UITextField!
    @IBOutlet weak var bioTxtField: UITextField!
    @IBOutlet weak var phoneTxtField: UITextField!
    
    @IBOutlet weak var genderTxtField: UITextField!
    
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var tapChangeProfilePicBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapToHideKeyboard()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let activityIndicator = common.startLoader(onView: self.view)

        let userProfile = UserProfile()
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        genderTxtField.inputView = pickerView
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profilePicView.isUserInteractionEnabled = true
        profilePicView.addGestureRecognizer(imageTap)
        profilePicView.layer.cornerRadius = profilePicView.frame.size.width / 2
        profilePicView.clipsToBounds = true
        profilePicView.layer.borderWidth = 2
        profilePicView.layer.borderColor = UIColor.black.cgColor
        tapChangeProfilePicBtn.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        let db = Firestore.firestore()
        let profileRef = db.collection("UserProfiles").document("Profile_\(uid)")
        
        profileRef.getDocument{(document, error) in
            if let document = document, document.exists {
                
                if let doc = document.data(),
                    let name = doc[userProfile.nameKey] as? String,
                    let username = doc[userProfile.usernameKey] as? String
//                    let website = doc[userProfile.websiteKey] as? String,
//                    let bio = doc[userProfile.bioKey] as? String,
//                    let phone = doc[userProfile.phoneKey] as? String,
//                    let gender = doc[userProfile.genderKey] as? String,
//                    let picURL = doc[userProfile.picURLKey] as? String
                    {
                    
                    self.profileNameTxtField.text = name
                    self.userNameTxtField.text = username
                    self.websiteTxtField.text = doc[userProfile.websiteKey] as? String ?? ""
                    self.bioTxtField.text = doc[userProfile.bioKey] as? String ?? ""
                    self.phoneTxtField.text = doc[userProfile.phoneKey] as? String ?? ""
                    self.genderTxtField.text = doc[userProfile.genderKey] as? String ?? ""
                    
                    do {
                        if let picURL = doc[userProfile.picURLKey] as? String{
                            let url = URL(string: picURL)
                            let data = try Data(contentsOf: url!)
                            self.profilePicView.image = UIImage(data: data)
                        }
                        
                    }
                    catch{
                        print(error)
                    }
                    
                }
                self.common.stopLoader(activityIndicator: activityIndicator)

                
                
            } else {
                self.common.stopLoader(activityIndicator: activityIndicator)

//                print("Document does not exist")
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func cancelBtn(_ sender: Any) {
//        //close current view controller
//        self.dismiss(animated: true, completion: nil)
//    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxtField.text = genderOption[row]
    }
    
    @IBAction func profileSaveBtn(_ sender: Any) {
        let userProfile = UserProfile()

        guard let username = (userNameTxtField.text)?.lowercased() else { return }
        guard let profileName = profileNameTxtField.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //        var picURL: URL? = nil
        
        // Firebase code here
        
        let db = Firestore.firestore()
        let profileRef = db.collection(userProfile.collectionName)
        
        profileRef.whereField(userProfile.usernameKey, isEqualTo: username).getDocuments {(snapshot, error) in
            if error != nil{
                
            }else{
                let suid = snapshot!.documents[0].data()[userProfile.uidKey]
                if( snapshot!.count > 1 || !(uid.isEqual(suid))){
                    let alert = UIAlertController(title: "Info", message: "'\(username)' is already taken!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                
            }
        }
        let storagePath = "users/\(uid)/profile/profile_pic.jpg"
        if(profilePicView.image != nil){
            common.uploadImageToCloud(profilePicView.image!, storagePath: storagePath) {url in
//                print("profile edit url!.absoluteString: \(url!.absoluteString)")
                profileRef.document("Profile_\(uid)").updateData([userProfile.picURLKey: url!.absoluteString]){ error in
                    if let error = error {
                        // Error
                        print("------------------\(error.localizedDescription)")
                    }else{
                        
                    }
                }
            }
        }
        //        print("pic URL:\(picURL)")
        
        let userProfileObject = [
            userProfile.nameKey: profileName,
            userProfile.usernameKey: username,
            userProfile.websiteKey: websiteTxtField.text ?? "",
            userProfile.bioKey: bioTxtField.text ?? "",
            userProfile.phoneKey: phoneTxtField.text ?? "",
            userProfile.genderKey: genderTxtField.text ?? "",
            
            ] as [String:Any]
        
        profileRef.document("Profile_\(uid)").updateData(userProfileObject){ error in
            if let error = error {
                // Error
                print("------------------\(error.localizedDescription)")
            }else{
                self.navigationController?.popViewController(animated: true)
//                self.dismiss(animated: true, completion: nil)
            }
        }
        
        //        postRef.setValue(postObject, withCompletionBlock: { error, ref in
        //            if error == nil {
        //                self.dismiss(animated: true, completion: nil)
        //            } else {
        //                // Handle the error
        //            }
        //        })
        
    }
    
    @IBAction func logOut(_ sender: Any) {
        try! Auth.auth().signOut()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = storyboard.instantiateViewController(withIdentifier: "ViewControllerSignIn")
        self.present(signInVC, animated: true, completion: nil)
        
        //        self.performSegue(withIdentifier: "toLogInScreen", sender: nil)
        
        
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

extension ProfileEditController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profilePicView.image = selectedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
