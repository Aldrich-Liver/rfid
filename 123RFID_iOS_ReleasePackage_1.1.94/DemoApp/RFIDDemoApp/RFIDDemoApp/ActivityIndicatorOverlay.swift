//
//  ActivityIndicatorOverlay.swift
//  RFIDDemoApp
//
//  Created by Dhanushka Adrian on 2023-05-17.
//  Copyright © 2023 Zebra Technologies Corp. and/or its affiliates. All rights reserved. All rights reserved.
//


import UIKit
import Foundation


@available(iOS 13.0, *)
private let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)


extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

@objc extension UIViewController {
    
    /// Set attributed string for message string
    /// - Parameters:
    ///   - text: text The text
    ///   - fontSize: fontSize The font size
    ///   - color: color The color
    /// - Returns: The attribut string
    private func attributedString(_ text: String, _ fontSize: CGFloat, _ color: UIColor) -> NSAttributedString {
        let attributedString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize), NSAttributedString.Key.foregroundColor: color])
        return attributedString
    }
    
    /// Get the top most view in the app
    /// — Returns: It returns current foreground UIViewcontroller
    private func topMostViewController() -> UIViewController {
        
        var topViewController: UIViewController? = UIWindow.key?.rootViewController
        while ((topViewController?.presentedViewController) != nil) {
            topViewController = topViewController?.presentedViewController
        }
        return topViewController!
        
    }
    
    /// Show alert with title and message
    /// - Parameters:
    ///   - message: message The message
    func showLoadingBar(message: String) {
        
        let alertController = UIAlertController(title:nil, message:message, preferredStyle: .alert)
        alertController.setValue(attributedString(message, 14, .black), forKey: "attributedMessage")
        
        if #available(iOS 13.0, *) {
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
            alertController.view.addSubview(activityIndicator)
            alertController.view.heightAnchor.constraint(equalToConstant: 120).isActive = true
            activityIndicator.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor, constant: 0).isActive = true
            activityIndicator.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -30).isActive = true
            topMostViewController().present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    /// Show only message with duration
    /// - Parameters:
    ///   - message: message The message
    ///   - time: time The time duration
    func showOnlyMessageWithDuration(message: String, time:Double) {
        
        let alertController = UIAlertController(title:nil, message:message, preferredStyle: .alert)
        alertController.setValue(attributedString(message, 14, .black), forKey: "attributedMessage")
        
        if #available(iOS 13.0, *) {
       
            alertController.view.addSubview(activityIndicator)
            alertController.view.heightAnchor.constraint(equalToConstant: 80).isActive = true
         
            topMostViewController().present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.hideLoadingView()
            }
        }
        
    }
    
    /// Show only success failure message with duration
    /// - Parameters:
    ///   - successMessage: successMessage The success message
    ///   - failureMessage: failureMessage The failure message
    ///   - time: time The duration
    ///   - isSucess: isSucess The sucess status
    func showOnlySuccessFailureMessageWithDuration(successMessage: String, failureMessage: String, time:Double , isSucess:Bool) {
        
        var alertControllerMessage:String = ""
        
        if isSucess {
            alertControllerMessage = successMessage
        }
        else {
            alertControllerMessage = failureMessage
        }
        let alertController = UIAlertController(title:nil, message:alertControllerMessage, preferredStyle: .alert)
        
        if #available(iOS 13.0, *) {
       
            alertController.view.addSubview(activityIndicator)
            alertController.view.heightAnchor.constraint(equalToConstant: 80).isActive = true
            topMostViewController().present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.hideLoadingView()
            }
        }
        
    }
    
    
    /// Show loading bar with duration
    /// - Parameters:
    ///   - message: message The message
    ///   - time: time The duration
    func showLoadingBarWithDuration(message:String ,time:Double) {
        
        let alertController = UIAlertController(title:nil, message:message, preferredStyle: .alert)
        alertController.setValue(attributedString(message, 14, .black), forKey: "attributedMessage")
        
        if #available(iOS 13.0, *) {
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
            alertController.view.addSubview(activityIndicator)
            alertController.view.heightAnchor.constraint(equalToConstant: 120).isActive = true
            activityIndicator.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor, constant: 0).isActive = true
            activityIndicator.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -30).isActive = true
            topMostViewController().present(alertController, animated: true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.hideLoadingView()
            }
        }
    }
    
    //Hide alert view
    func hideLoadingView(){
        if #available(iOS 13.0, *) {
            activityIndicator.stopAnimating()
            topMostViewController().dismiss(animated: true)
            topMostViewController().view.removeFromSuperview()
            
        }
    }
    
}

