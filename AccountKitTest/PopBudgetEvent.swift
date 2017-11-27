//
//  PopBudgetEvent.swift
//  AccountKitTest
//
//  Created by Лев Купчинов on 17.11.17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

class PopBudgetEvent: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let eventValue = ["Meeting", "Birthday"]

    @IBOutlet weak var eventPickerView: UIPickerView!
    @IBOutlet weak var viewPicker: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewPicker.layer.cornerRadius = 10.0
        viewPicker.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }

    
    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eventValue[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventValue.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventIndex = eventValue[row]
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
