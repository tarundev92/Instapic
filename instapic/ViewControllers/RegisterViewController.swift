//
//  RegisterViewController.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 26/09/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore


class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email_address: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    var activityView:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapToHideKeyboard()
        
        signUpBtn.addTarget(self, action: #selector(signUp), for: .touchUpInside)


        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//        activityView.color = secondaryColor
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        activityView.center = signUpBtn.center
        
        username.delegate = self
        email_address.delegate = self
        password.delegate = self
        
        username.addTarget(self, action: #selector(textFieldValidator), for: .editingChanged)
        email_address.addTarget(self, action: #selector(textFieldValidator), for: .editingChanged)
        password.addTarget(self, action: #selector(textFieldValidator), for: .editingChanged)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func textFieldValidator(_ target:UITextField) {
        let username = self.username.text
        let email = email_address.text
        let password = self.password.text
        let formFilled = username != nil && username != "" && email != nil && email != "" && password != nil && password != ""
//        setContinueButton(enabled: formFilled)
        signUpBtn.isEnabled = formFilled
    }
    


    @objc func signUp() {
        guard let username = username.text else { return }
        guard let email = email_address.text else { return }
        guard let pass = password.text else { return }
        
//        setContinueButton(enabled: false)
        signUpBtn.isEnabled = false
//        signUpBtn.setTitle("", for: .normal)
        signUpBtn.backgroundColor = UIColor(red: 164/225, green: 200/225, blue: 225/225, alpha: 1)
//        signUpBtn.backgroundColor = UIColor(red: 60, green: 146, blue: 225, alpha: 1)
        
        activityView.startAnimating()
        
        let userProfile = UserProfile()
        let db = Firestore.firestore()
        let profileRef = db.collection("UserProfiles")
        
        profileRef.whereField(userProfile.usernameKey, isEqualTo: username).getDocuments {(snapshot, error) in
            if error != nil{
                print("Error: \(error!.localizedDescription)")
                
            }else{
                if( snapshot!.count > 0 ){
                    let alert = UIAlertController(title: "Info", message: "'\(username)' is already taken!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    return
                }
                
            }
        }
        
        
        Auth.auth().createUser(withEmail: email, password: pass) { user, error in
            if error == nil && user != nil {
//                print("User created!")
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username

                changeRequest?.commitChanges { error in
                    if error == nil {
//                        print("User display name changed!")
                        self.dismiss(animated: false, completion: nil)
                    } else {
//                        self.signUpBtn.setTitle("Sign Up", for: .normal)
                        self.signUpBtn.backgroundColor = UIColor(red: 60, green: 146, blue: 225, alpha: 1)
                        self.signUpBtn.isEnabled = true
                        let alert = UIAlertController(title: "Info", message: error!.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        print("Error: \(error!.localizedDescription)")
                    }
                }
                let userProfileObject = [
                    userProfile.uidKey: user!.user.uid,
                    userProfile.usernameKey: username,
                    userProfile.nameKey: username,
                    userProfile.picURLKey: "https://firebasestorage.googleapis.com/v0/b/instapic-bb197.appspot.com/o/users%2F1profile_pic_default.png?alt=media&token=7a3dca7e-d4d0-4293-a186-5da6e3aba3d5",
                    userProfile.followersCountKey: 0,
                    userProfile.followingCountKey: 0,
                    userProfile.postCountKey: 0,
                    userProfile.createdKey: FieldValue.serverTimestamp(),
                    ] as [String:Any]
                
                profileRef.document("Profile_\(user!.user.uid)").setData(userProfileObject){ error in
                    if let error = error {
                        // Error
                        print("------------------\(error.localizedDescription)")
                    }else{
                        self.dismiss(animated: true, completion: {self.performSegue(withIdentifier: "toUserSignInScreen", sender: self)})
                        
                    }
                }
                
                
                
                
            } else {
//                self.signUpBtn.setTitle("Sign Up", for: .normal)
                self.signUpBtn.backgroundColor = UIColor(red: 60/225, green: 146/225, blue: 225/225, alpha: 1)
                self.signUpBtn.isEnabled = true
                let alert = UIAlertController(title: "Info", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                print("Error: \(error!.localizedDescription)")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Resigns the target textField and assigns the next textField in the form.
        textField.resignFirstResponder()
        switch textField {
//        case username:
//            username.resignFirstResponder()
//            email_address.becomeFirstResponder()
//            break
//        case email_address:
//            email_address.resignFirstResponder()
//            password.becomeFirstResponder()
//            break
        case password:
            signUp()
            break
        default:
            break
        }
        return true
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
