//
//  PopUpInvite.swift
//  AccountKitTest
//
//  Created by Лев Купчинов on 17.11.17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

    var dateIndex = ""

class PopUpInvite: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    let dateValue = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" ]

    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var inviteLabel: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inviteLabel.layer.cornerRadius = 10.0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dateValue[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dateValue.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dateIndex = dateValue[row]
    }
    
    @IBAction func okButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
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
