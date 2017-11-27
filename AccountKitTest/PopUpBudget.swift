//
//  PopUpBudget.swift
//  AccountKitTest
//
//  Created by Лев Купчинов on 13.11.17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit


class PopUpBudget: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let budgetValue = ["Free", "Chargeable"]
    
    @IBOutlet weak var viewPopUp: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewPopUp.layer.cornerRadius = 10.0
        viewPopUp.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }

    @IBAction func okButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return budgetValue[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return budgetValue.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        budgetIndex = budgetValue[row]
    }
    
}
