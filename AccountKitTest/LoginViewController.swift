//
//  LoginViewController.swift
//  AccountKitTest
//
//  Created by Test on 01.11.17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit
import AccountKit

class LoginViewController: UIViewController, AKFViewControllerDelegate {
    
    var accountKit: AKFAccountKit!
    
    @IBOutlet weak var loginWithPhoneOutlet: UIButton!
    @IBOutlet weak var loginWithEmailOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonStyle()
        gradiented()
        //Init Account Kit
        if accountKit == nil {
            self.accountKit = AKFAccountKit(responseType: .accessToken)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (accountKit.currentAccessToken != nil) {
            print("User already logged in, go to the home screen")
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "ShowHome", sender: self)
            })
        }
        
    }
    
    func prepareLoginViewController(_ loginViewController: AKFViewController) {
        loginViewController.delegate = self
        loginViewController.setAdvancedUIManager(nil)
        
        //Customize the theme
        let theme = AKFTheme.default()
        theme.headerBackgroundColor = UIColor(red: 53.0/255.0, green: 104.0/255.0, blue: 224.0/255.0, alpha: 1)
        theme.headerTextColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        theme.iconColor = UIColor(red: 53.0/255.0, green: 104.0/255.0, blue: 224.0/255.0, alpha: 0.7)
        theme.inputTextColor = UIColor(white: 0.4, alpha: 1.0)
        theme.statusBarStyle = .lightContent
        theme.textColor = UIColor(white: 0.3, alpha: 1.0)
        theme.titleColor = UIColor(red: 0.247, green: 0.247, blue: 0.247, alpha: 1)
        loginViewController.setTheme(theme)
    }
    
    @IBAction func loginWithPhone(_ sender: UIButton) {
        //login with Phone
        let inputState = UUID().uuidString
        let viewController = accountKit.viewControllerForPhoneLogin(with: nil, state: inputState) as AKFViewController
        viewController.enableSendToFacebook = true
        self.prepareLoginViewController(viewController)
        self.present(viewController as! UIViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func loginWithEmail(_ sender: UIButton) {
        //login with Email
        let inputState = UUID().uuidString
        let viewController = accountKit.viewControllerForEmailLogin(withEmail: nil, state: inputState) as AKFViewController
        self.prepareLoginViewController(viewController)
        self.present(viewController as! UIViewController, animated: true, completion: nil)
    }
    
    func buttonStyle(){
        loginWithEmailOutlet.layer.borderWidth = 1
        loginWithEmailOutlet.layer.borderColor = UIColor(red: 79.0/255.0, green: 119.0/255.0, blue: 237.0/255.0, alpha: 1).cgColor
        loginWithEmailOutlet.layer.cornerRadius = 10.0
        loginWithPhoneOutlet.layer.cornerRadius = 10.0
        loginWithEmailOutlet.layer.cornerRadius = 0.5 * loginWithEmailOutlet.bounds.size.height
        loginWithPhoneOutlet.layer.cornerRadius = 0.5 * loginWithEmailOutlet.bounds.size.height
    }
    
    func gradiented() {
        let gradient: CAGradientLayer = CAGradientLayer()
        let colorTop = UIColor(red: 112.0/255.0, green: 219.0/255.0, blue: 155.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 86.0/255.0, green: 197.0/255.0, blue: 238.0/255.0, alpha: 1.0).cgColor
        gradient.colors = [colorTop, colorBottom]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = loginWithPhoneOutlet.bounds
        gradient.cornerRadius = 5
        loginWithPhoneOutlet.clipsToBounds = true
    }

}
