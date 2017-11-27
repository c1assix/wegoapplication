//
//  AddEventViewController.swift
//  AccountKitTest
//
//  Created by Лев Купчинов on 25.11.17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AddEventViewController: UIViewController {
    
    var ref: DatabaseReference?
    var eventName = ""
    var eventAddress = ""
    var eventDecription = ""
    var eventPrice = ""
    var latitude = ""
    var longitude = ""
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var viewCard: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        print(count)
        self.nameTextField.delegate = self as? UITextFieldDelegate
        viewCard.layer.cornerRadius = 10
        viewCard.layer.shadowColor = UIColor(red: 60.0/255.0, green: 108.0/255.0, blue: 222.0/255.0, alpha: 0.25).cgColor
        viewCard.layer.shadowOpacity = 1
        viewCard.layer.shadowOffset = CGSize.zero
        viewCard.layer.shadowRadius = 15
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addAction(_ sender: Any) {
        eventName = nameTextField.text!
        ref?.child("places").child("\(count)").child("name").setValue(eventName)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShoudReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
