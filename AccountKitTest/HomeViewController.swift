//
//  HomeViewController.swift
//  AccountKitTest
//
//  Created by Test on 01.11.17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit
import AccountKit
import FirebaseDatabase

fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default: return rhs < lhs
    }
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


class HomeViewController: UIViewController {
    
        var ref: DatabaseReference!
    
    @IBOutlet weak var accountID: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var phoneOrEmailLabel: UILabel!
    
    var accountKit: AKFAccountKit!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()


        //Init Account Kit
        if accountKit == nil {
            self.accountKit = AKFAccountKit(responseType: .accessToken)
            
            accountKit.requestAccount({ (account, error) in
                self.accountID.text = account?.accountID
                if account?.emailAddress?.characters.count > 0 {
                    //if the user is logged with Email
                    self.typeLabel.text = "Email Address"
                    self.phoneOrEmailLabel.text = account!.emailAddress
                } else if account?.phoneNumber?.phoneNumber != nil {
                    self.typeLabel.text = "Phone Number"
                    self.phoneOrEmailLabel.text = account!.phoneNumber?.stringRepresentation()
                    self.ref?.child(self.typeLabel.text!).childByAutoId().setValue("ID \(self.accountID.text!): \(self.phoneOrEmailLabel.text!)")
                }
            })
        }
        
    }
    
    @IBAction func logout(_ sender: UIButton) {
        accountKit.logOut()
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "ShowLogin", sender: self)
        })
        //dismiss(animated: true, completion: nil)
    }

}
