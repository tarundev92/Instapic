//
//  ViewControllerSignIn.swift
//  instagram
//
//  Created by Tarun Dev Thalakunte Rajappa on 11/09/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class ViewControllerSignIn: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var user_name: UITextField!{
        didSet {
            user_name.layer.cornerRadius =  8.0
            user_name.layer.borderColor = UIColor().colorFromHex("C6C6C8").cgColor
            user_name.layer.borderWidth = 1
            let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 2.0))
            user_name.leftView = leftView
            user_name.leftViewMode = .always
            
            
        }
    }
    @IBOutlet weak var password: UITextField!{
        didSet {
            password.layer.cornerRadius =  8.0
            password.layer.borderColor = UIColor().colorFromHex("C6C6C8").cgColor
            password.layer.borderWidth = 1
            let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 2.0))
            password.leftView = leftView
            password.leftViewMode = .always
            
        }
    }
    
    @IBOutlet weak var logInBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tapToHideKeyboard()
        logInBtn.addTarget(self, action: #selector(logIn), for: .touchUpInside)

        user_name.delegate = self
        password.delegate = self
        
        user_name.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        password.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        
    }
    
    @objc func textFieldChanged(_ target:UITextField) {
        let email = user_name.text
        let password = self.password.text
        let formFilled = email != nil && email != "" && password != nil && password != ""
//        setContinueButton(enabled: formFilled)
        logInBtn.isEnabled = formFilled
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Resigns the target textField and assigns the next textField in the form.
        textField.resignFirstResponder()
        
        switch textField {
        case user_name:
            user_name.resignFirstResponder()
            password.becomeFirstResponder()
            break
        case password:
            logIn()
            break
        default:
            break
        }
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "toUserFeedScreen", sender: self)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func logIn() {
        
        guard let email = user_name.text else { return }
        guard let pass = password.text else { return }
        
//        logInBtn.isEnabled = false
        
//        setContinueButton(enabled: false)
        
//        logInBtn.setTitle("", for: .normal)
        self.logInBtn.backgroundColor = UIColor(red: 164/225, green: 200/225, blue: 235/225, alpha: 1)
        self.logInBtn.isEnabled = false
//        activityView.startAnimating()
//        print("BEFORE AUTH-----------------")
        Auth.auth().signIn(withEmail: email, password: pass) { user, error in
            if error == nil && user != nil {
//                self.dismiss(animated: false, completion: nil)
                self.performSegue(withIdentifier: "toUserFeedScreen", sender: nil)
                
            } else {
                let alert = UIAlertController(title: "Info", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
//                self.logInBtn.setTitle("Log In", for: .normal)
                self.logInBtn.backgroundColor = UIColor(red: 62/225, green: 144/225, blue: 225/225, alpha: 1)
                self.logInBtn.isEnabled = true
                print("Error logging in: \(error!.localizedDescription)")
            }
        
    }
    }
    
    //    @IBAction func signUp(_ sender: UIButton) {
//
//    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
