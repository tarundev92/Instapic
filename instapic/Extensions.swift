//
//  Extensions.swift
//  instagram
//
//  Created by Tarun Dev Thalakunte Rajappa on 11/09/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    func colorFromHex(_ hex : String) -> UIColor {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.count != 6{
            return UIColor.black
        }
        
        var rgb : UInt32 = 0
        Scanner(string: hexString).scanHexInt32(&rgb)
        return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16)/255.0,
                            green: CGFloat((rgb & 0x00FF00) >> 8)/255.0,
                            blue: CGFloat(rgb & 0x0000FF)/255.0, alpha: 1.0)
        
    }
}
extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
    func tapToHideKeyboard(){
//        let TapOnScreen:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(TapOnScreen)
        
        let TapOnScreen: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        TapOnScreen.cancelsTouchesInView = false
        view.addGestureRecognizer(TapOnScreen)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
}

extension Array {
    func removingDuplicates<T: Equatable>(byKey key: KeyPath<Element, T>)  -> [Element] {
        var result = [Element]()
        var seen = [T]()
        for value in self {
            let key = value[keyPath: key]
            if !seen.contains(key) {
                seen.append(key)
                result.append(value)
            }
        }
        return result
    }
}
//let withoutDuplicates = searchResults.removingDuplicates(byKey: \.index)
//let withoutDuplicates = searchResults.removingDuplicates(byKey: { $0.index })


